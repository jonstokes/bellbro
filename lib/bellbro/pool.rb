module Bellbro
  module Pool

    def with_connection(pool_name: nil, &block)
      retryable(sleep: 0.5) do
        connection_pool(pool_name: pool_name).with &block
      end
    end

    def connection_pool(pool_name: nil)
      self.class.connection_pool(pool_name: pool_name)
    end

    def self.included(klass)
      klass.extend(self)

      class << klass
        def pool(pool_name)
            @pool_name = pool_name
        end
        
        def pool_name
          @pool_name
        end

        def connection_pool(pool_name: nil)
          Bellbro::Settings.connection_pools[pool_name || @pool_name]
        end
      end
    end
  end
end