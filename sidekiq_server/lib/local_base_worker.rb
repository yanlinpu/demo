#encoding: utf-8
# 中心内部同步
module QueueServer
  class LocalBaseWorker < QueueServer::BaseWorker
    private

    def sync_success(task)
      master_timestamp = QueueServer::RepoRoute.get_master_timestamp
      QueueServer::RepoRoute.update_repo_status task['prj'], sync_status(task['t'].to_s, master_timestamp), task['t']
    end

    # 同一个项目处理任务时，必须先处理完上一个任务，才能处理下一个任务
    # &block 同步执行的代码块
    def locked_perform(task, &block)
      task_no = task['tno']
      raise ArgumentError, 'block must given' unless block_given?
      sync_lock = QueueServer::SyncLock.new redis: WORKER_REDIS, type: 'local_worker', path: task['prj'], task_no: task_no
      begin
        @mutex.synchronize do
          sync_lock.lock
          sleep(1) && redo if sync_lock.locked?
          # 修改仓库状态为同步中
          QueueServer::RepoRoute.update_repo_status task['prj'], STATUS_SYNCING
          # 开始执行任务
          Logger.info "Task start: #{task}"
          result = block.call
          # 如果result是false，抛出异常
          # raise SyncExecFail, "Task handle fail: task:#{task}, result: #{result}" unless result
          # 修改router状态
          sync_success(task)
          Logger.info "Task finish: #{task}, result: #{result}"
        end
      rescue => e
        Logger.info "Task ERROR: \ntask:#{task}, task_no: #{task_no}, error_class: #{e.class}, error_msg: #{e.message}"
        fail e
      ensure
        sync_lock.unlock
        @mutex.unlock if @mutex.locked?
      end
    end

    #处理创建项目同步
    def handle_create(task)
      lambda do
        puts '------create-------'
      end
    end
  end
end