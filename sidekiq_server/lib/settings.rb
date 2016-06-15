#encoding: utf-8
module QueueServer
  class Settings < ::Settingslogic
    config_file =  File.join(::WORK_DIR, 'config.yml')
    source config_file
  end
  Settings['current_id'] ||= Settings['hostname']
end
