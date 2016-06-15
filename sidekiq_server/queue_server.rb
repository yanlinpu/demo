#encoding: utf-8
require 'rubygems'
require 'bundler/setup'
require 'sidekiq'
require 'redis'
require 'yaml'
require 'fileutils'
require 'singleton'
require 'redis-namespace'
require 'logger'
require 'uri'
require 'net/http'
require 'json'
require 'settingslogic'

ENVIRONMENT = ENV['RACK_ENV'] || 'development'
# 当前工作目录
WORK_DIR = File.dirname File.realpath(__FILE__)
require_relative 'lib/settings'

# 队列redis
REDIS_URL = "redis://#{QueueServer::Settings.redis.sync_worker_redis.host}:#{QueueServer::Settings.redis.sync_worker_redis.port}/#{QueueServer::Settings.redis.sync_worker_redis.db}"
puts "sidekiq redis url <==========> #{REDIS_URL}"
WORKER_REDIS = Redis.new(url: REDIS_URL)
# local redis
LOCAL_REDIS_URL = "redis://#{QueueServer::Settings.redis.route_redis.host}:#{QueueServer::Settings.redis.route_redis.port}/#{QueueServer::Settings.redis.route_redis.db}"
ROUTER_REDIS = Redis.new(url: LOCAL_REDIS_URL)

# 仓库同步状态
STATUS_WAIT_SYNC = 1   #等待同步
STATUS_SYNCING = 2     #正在同步中
STATUS_SYNC_FINISH = 3 #同步完成

require_relative 'lib/helper'

module QueueServer
  class RouterNotFound < Exception; end 
  class DCRouterNotFound < Exception; end 
  class RouterInitFail < Exception; end
  class SyncExecFail < Exception; end 

  class BaseWorker 
    extend QueueServer::Helper
    include Sidekiq::Worker 
    include QueueServer::Helper

    def initialize
      @mutex = Mutex.new
    end

    def self.logger(m)
      logger.info(m)
    end
  end

  class Logger
    def self.info(message)
      if ENVIRONMENT == 'production'
        Sidekiq.logger.info(message)
      else
        puts message
      end
    end
  end
end

require_relative 'lib/repo_route'
require_relative 'lib/sync_lock'
require_relative 'lib/local_base_worker'