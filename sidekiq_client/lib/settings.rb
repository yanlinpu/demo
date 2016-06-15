#encoding: utf-8
module QueueClient
  class Settings < ::Settingslogic
    config_file =  File.join(::WORK_DIR, 'config.yml')
    source config_file
  end
end
