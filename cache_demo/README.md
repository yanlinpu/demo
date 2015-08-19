##README

####流程
    - rvm use 2.1.2@rails4.2.1
    - rails new cache_demo -d mysql
    - mv app/views/layouts/application.html.erb app/views/layouts/application.html.haml
    - vim app/views/layouts/application.html.haml
    - vim Gemfile #add  gem "dalli" gem "memcached" gem 'redis-rails' gem 'settingslogic' gem 'haml-rails'
    - bundle install
    - rails g scaffold products name:string price:integer
    - rake db:create
    - rake db:migrate
    - vim config/application.yml #配置文件
    - vim config/initializers/1-settings.rb #settingslogic 使Settings 生效
    - vim config/environments/development.rb #redis-cache配置  perform_caching=> true
    - vim config/initializers/session_store.rb
    - vim config/initializers/redis.rb #定义全局变量 $redis_cache
    - vim app/helpers/products_helper.rb #redis方法
    - vim app/views/products/show.html.haml #调用helper方法
    - vim app/views/products/index.html.haml #cache 片段缓存
    - vim app/controllers/products_controller.rb  #index action 调用redis
    
####redis-string

    $ rails c 
    $ $redis_cache.set('foo','bar')                         #=> OK  (nil->"")
    $ $redis_cache['foo3']='bar3'                           #=> 'bar3'
    $ $redis_cache.get('foo')                               #=> 'bar' or nil
    $ $redis_cache['foo3']                                  #=> 'bar3'
    $ $redis_cache.del('foo')                               #=> 1  or  0(说明不存在)
    $ $redis_cache.exists('foo')                            #=> true or false
    $ $redis_cache.expire('foo',10)                         #=> true (10s)
    $ $redis_cache.expireat('foo',Time.now.to_i+10.seconds) #=> true (同上)
    $ $redis_cache.ttl('foo')                               #=> -1(表示永远存在)  或者具体存在生存时间（57 ...）
    $ $redis_cache.persist('foo')                           #=> -1 取消时间限制
    $ $redis_cache.rename('foo','foo2')                     #=> OK 重命名 (名字相同error）
    $ $redis_cache.type('foo')                              #=> none (key不存在) string (字符串) list (列表) set (集合) zset (有序集) hash (哈希表)
    $ $redis_cache.keys('foo*')                             #=> ["foo2", "foo"]
    $ $redis_cache.getrange 'foo3', 1,3                     #=> 'ar3' (key 不存在返回空字符串 '')
    $ $redis_cache.strlen('foo3')                        [rails-redis-string](http://www.cnblogs.com/fanxiaopeng/p/4197740.html)
    [redis-tutorial](http://www.runoob.com/redis/redis-tutorial.html)       #=> 4  (nil | key不存在 -> 0)
    $ $redis_cache.set('counter', '123456')
    $ $redis_cache.incr('counter')                          #=> 123457  (+=1)
    $ $redis_cache.incrby('counter',100)                    #=> 123557  (+=100)
    $ $redis_cache.decr('counter')                          #=> 123556  (-=1)
    $ $redis_cache.decrby('counter',100)                    #=> 123456  (-=100)
    
####redis-list

    $ $redis_cache.lpush('fruits','apple')                  #=> 1  (从最前面添加 list.length)
    $ $redis_cache.lpush('fruits','orange')                 #=> 2  (从最前面添加 list.length)
    $ $redis_cache.lpush('fruits','banana')                 #=> 3  (从最前面添加 list.length)
    $ $redis_cache.rpush('fruits','mongo')                  #=> 4  (从最后面添加 list.length)
    $ $redis_cache.lrange('fruits',0,-1)                    #=> ["banana", "orange", "apple", "mongo"]
    
####redis-hash  

    $ $redis_cache.hmset('test3', :id, 1, :user, 'daniel')  #=> OK
    $ $redis_cache.hmget('test3', :id, :user)               #=> ["1", "daniel"] $redis_cache.hgetall('test3')['id']
    $ $redis_cache.hgetall 'test3'                          #=> {"id"=>"1", "user"=>"daniel"}
    $ some_hash = {id: 2, user: "ylp", time: Time.now}
    $ $redis_cache.mapped_hmset 'test4', some_hash          #=> OK (映射式的存取方法)
    $ $redis_cache.mapped_hmget 'test4', :user              #=> 'ylp'

####redis-set

    $ $redis_cache.sadd('test5','redis')                    #=> true
    $ $redis_cache.sadd('test5','mysql')                    #=> true  (加在最前面)
    $ $redis_cache.sadd('test5','pg')                       #=> true  (加在最前面)
    $ $redis_cache.smembers('test5')                        #=> ["pg", "mysql", "redis"]
 
####redis-资料
    
    #[rails-redis-string](http://www.cnblogs.com/fanxiaopeng/p/4197740.html)
    #[redis-tutorial](http://www.runoob.com/redis/redis-tutorial.html)
 
####better-error

    group :development do
        gem 'better_errors', '~> 2.1.1' # 错误能够在页面调试 
	gem 'brakeman', '~> 3.0.5' # 检测安全漏洞  brakeman -o outfile.txt
    end

