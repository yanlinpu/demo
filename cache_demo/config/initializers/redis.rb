# coding: utf-8
# create an initializer in config/initializers/redis.rb and add the following:

cache_url = Settings.redis.cache_url
$redis_cache = Redis.new(:url => cache_url )
