module QueueServer
  module Helper

    # 同步状态
    def sync_status(task_time, master_time)
      task_time == master_time ? STATUS_SYNC_FINISH : STATUS_WAIT_SYNC
    end
  end

  module LockHelper
    def lock_key(type, path)
      "QS:#{type}:lock:#{path}"
    end

    def lock_val(task_no, backend)
      "#{task_no},#{backend}"
    end

    # 在同步中的项目列表redis key
    def syncing_list_key(type, backend)
      "QS:#{type}:syncing_repo:#{backend}"
    end

    def syncing_list_val(task_no, path)
      "#{task_no},#{path}"
    end
  end
end
