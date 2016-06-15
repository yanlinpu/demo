#encoding: utf-8
require 'sidekiq'
require 'singleton'
require 'settingslogic'
require 'redis'
require 'redis-namespace'

WORK_DIR = File.dirname File.realpath(__FILE__)
require_relative 'lib/settings'

class ProjectSyncClient
  include Singleton
  include Sidekiq
  STATUS_WAIT_SYNC = 1    #等待同步
  STATUS_SYNCING = 2      #正在同步中
  STATUS_SYNC_FINISH = 3  #同步完成

  # router_redis_config 项目redis路由redis配置，{'host'=> '127.0.0.1', 'port'=> 6379, 'db'=> 0}
  # worker_redis_config 项目同步队列redis配置，{'host'=> '127.0.0.1', 'port'=> 6379, 'db'=> 0, 'namespace' => 'yanlp'}
  def initialize
    @router_redis = Redis.new url: "redis://#{QueueClient::Settings.redis.route_redis.host}:#{QueueClient::Settings.redis.route_redis.port}/#{QueueClient::Settings.redis.route_redis.db}",
                              password: QueueClient::Settings.redis.route_redis.password
    worker_redis_url = "redis://#{QueueClient::Settings.redis.sync_worker_redis.host}:#{QueueClient::Settings.redis.sync_worker_redis.port}/#{QueueClient::Settings.redis.sync_worker_redis.db}"
    @worker_redis = Redis.new url: worker_redis_url, password: QueueClient::Settings.redis.sync_worker_redis.password
    redis = Redis::Namespace.new(QueueClient::Settings.redis.sync_worker_redis.namespace, redis: @worker_redis)
    @sidekiq_client = Sidekiq::Client.new ConnectionPool.new { redis }
  end

  # 推送同步消息
  def push(pathname, action, other_info = nil)
    begin
      update_timestamp = Time.now.to_i
      @router_redis.set 'master_timestamp', update_timestamp.to_s
      @router_redis.hset pathname, QueueClient::Settings.hostname, "#{STATUS_WAIT_SYNC} & "

      # 获取任务编号
      task_no = get_queue_task_no

      # 队列参数
      args = {prj: pathname, act: action, t: update_timestamp, tno: task_no}
      args[:o] = other_info if other_info

      # 推送消息
      @sidekiq_client.push 'queue' => QueueClient::Settings.queue_name, 'class' => 'ProjectSyncWorker', 'args' => [args]
    rescue => e
      logger.info "push msg error: ErrorClass: #{e.class}, Message: #{e.message}, pathname: #{pathname}, action: #{action}, other: #{other_info}, backtrace: \n#{e.backtrace.join("\n")}"
    end
  end

  # 获取队列的编号
  def get_queue_task_no
    key = "yanlp:last_task_no"
    @worker_redis.incr key
  end

  def logger
    @logger ||= Logger.new File.join(Dir.pwd,"logs", "sync_client.log")
  end

  def self.push(pathname, action, other_info = nil)
    self.instance.push pathname, action, other_info
  end
end


p ProjectSyncClient.push('github/yanlinpu','create')
# lrange yanlp:queue:yanlinpu 0 -1
# "{\"retry\":true,\"queue\":\"yanlinpu\",\"class\":\"ProjectSyncWorker\",
# \"args\":[{\"prj\":\"github/yanlinpu\",\"act\":\"create\",\"t\":1465984653,\"tno\":1}],
# \"jid\":\"3e2a7c3ec8778a3a0c495554\",\"enqueued_at\":1465984653.7339952}"