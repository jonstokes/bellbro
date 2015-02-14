module Bellbro
  module RedisPool
    def with_connection
      self.class.with_connection do |c|
        yield c
      end
    end

    def self.included(klass)
      class << klass

        def set_db(default)
          @default_db_name = default.to_sym
        end

        def with_connection
          retryable(sleep: 0.5) do
            model_pool.with do |c|
              yield c
            end
          end
        end

        def model_pool
          @model_pool ||= Bellbro::Settings.redis_pool[@default_db_name]
        end
      end

    end
  end
end