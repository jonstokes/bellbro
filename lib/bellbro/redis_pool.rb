module Bellbro
  module Pool
    def self.included(klass)
      klass.extend(self)

      class << klass
        def pool(conn_pool)
          self.class_eval do
            @connection_pool = conn_pool
          end
        end
      end
    end

    def with_connection(&block)
      retryable(sleep: 0.5) do
        connection_pool.with &block
      end
    end

    def connection_pool
      @connection_pool
    end
  end

end