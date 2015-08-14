require 'yaml'

YAML::ENGINE.yamler = 'psych'

class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env
end

#
# redis
#
Settings['redis'] ||= Settings.new({})
Settings.redis['redis_host'] ||= 'localhost'
Settings.redis['redis_port'] ||= '6379'
Settings.redis['redis_db'] ||= '0'
Settings.redis['redis_url'] = "redis://#{Settings.redis['redis_host']}:#{Settings.redis['redis_port']}/#{Settings.redis['redis_db']}"


#
# redis cache
#
Settings['redis'] ||= Settings.new({})
Settings.redis['cache_host'] ||= 'localhost'
Settings.redis['cache_port'] ||= '6379'
Settings.redis['cache_db'] ||= '0'
Settings.redis['cache_url'] = "redis://#{Settings.redis['cache_host']}:#{Settings.redis['cache_port']}/#{Settings.redis['cache_db']}"
