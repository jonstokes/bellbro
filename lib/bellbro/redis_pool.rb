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
            Bellbro::Settings.redis_pool.with do |c|
              c.select(model_db)
              yield c
            end
          end
        end

        def model_db
          @model_db ||= Bellbro::Settings.redis_databases[@default_db_name]
        end
      end

    end
  end
end