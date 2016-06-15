#encoding: utf-8
module QueueServer
  class RepoRoute
    class << self
      attr_accessor :route_redis

      def route_redis
        @route_redis ||= ROUTER_REDIS
      end

      def get_master_timestamp
        route_redis.get('master_timestamp')
      end

      # 修改本中心项目当前后端机redis状态信息
      def update_repo_status(path, status, timestamp=nil)
        backend = QueueServer::Settings.current_id
        route_redis.hset path, backend, "#{status} & #{timestamp}"
      end
    end
  end
end
