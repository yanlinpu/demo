module ProductsHelper
  def set_product_cache(product)
    return unless product.try(:id)
    key = Digest::SHA1.hexdigest("#{product.id}, #{product.name}")
    $redis_cache.hset(key, 'product_id', product.id)
    $redis_cache.hset(key, 'product_name', product.name)
    $redis_cache.hset(key, 'product_price', product.price)
    in_times = Settings.cache_expires_in.in_seconds
    $redis_cache.expireat key, (Time.now + in_times.seconds).to_i
  end
end
