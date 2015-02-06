module Bellbro
  module RedisPool
    def self.included(klass)
      klass.extend(self)
    end

    def with_redis(&block)
      retryable(sleep: 0.5) do
        redis_pool.with &block
      end
    end

    def redis_pool
      @redis_pool
    end

    def redis_pool=(pool)
      @redis_pool = pool
    end
  end

end