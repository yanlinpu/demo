#encoding: utf-8
require_relative 'queue_server'
#sidekiq server配置
Sidekiq.configure_server do |config|
  config.redis = {
    url: REDIS_URL,
    namespace: QueueServer::Settings.redis.sync_worker_redis.namespace
  }
end

require_relative 'lib/worker/project_sync_worker'