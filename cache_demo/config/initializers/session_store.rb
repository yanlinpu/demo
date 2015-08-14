# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_cache_demo_session'


CacheDemo::Application.config.session_store :redis_store,
                                            :servers => {
                                              :host => Settings.redis.cache_host,
                                              :port => Settings.redis.cache_port,
                                              :db => Settings.redis.cache_db,
                                              # :password => "mysecret",
                                              :namespace => Settings.redis.cache_namespace
                                            }
                                            # :expires_in => 90.minutes
