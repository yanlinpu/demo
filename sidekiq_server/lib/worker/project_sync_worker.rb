#encoding: utf-8
class ProjectSyncWorker < QueueServer::LocalBaseWorker
  sidekiq_options queue: QueueServer::Settings.current_id, retry: 5, backtrace: true # 这指定队列的名称，重试次数

  def perform(task)
    block = self.__send__("handle_#{task['act']}", task)
    locked_perform(task, &block)
  end

end
