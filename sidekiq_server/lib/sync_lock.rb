#encoding: utf-8
module QueueServer
  class SyncLock
    extend QueueServer::LockHelper
    include QueueServer::LockHelper

    @@redis = nil
    def initialize(options = {})
      @@redis ||= options[:redis]
      @type = options[:type]
      @path = options[:path]
      @task_no = options[:task_no]    
      @lock_key, @lock_val = lock_key(@type, @path), lock_val(@task_no, QueueServer::Settings.current_id)
    end

    #加锁
    def lock
      @@redis.sadd @lock_key, @lock_val
      add_syncing_repo
    end

    #解锁
    def unlock
      @@redis.srem @lock_key, @lock_val
      remove_syncing_repo
    end

    #是否有锁
    def locked?
      values = @@redis.smembers @lock_key
      values.map! { |v| v.split(',').first.to_i }
      @task_no != values.min
    end

    #将正在同步的项目加入同步中的项目列表
    def add_syncing_repo
      @@redis.sadd syncing_list_key(@type, QueueServer::Settings.current_id), syncing_list_val(@task_no, @path)
    end 

    #移除正在同步中的repo，从同步中的项目列表
    def remove_syncing_repo
      @@redis.srem syncing_list_key(@type, QueueServer::Settings.current_id), syncing_list_val(@task_no, @path)
    end

    class << self
      def redis
        @@redis
      end 

      def redis=(redis)
        @@redis = redis
      end 

      #清理后端机正在同步中的项目
      def clear_syncing_list(type, backend)
        redis_key = syncing_list_key(type, backend)
        list = redis.smembers redis_key
        list.each do |val|
          task_no, path = val.split(',', 2)
          #将该项目的task_no从项目同步锁中删除
          redis.srem lock_key(type, path), lock_val(task_no, backend)
        end
        redis.del redis_key
      end
    end

  end
end
