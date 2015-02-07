module Bellbro
  module Pool
    def self.included(klass)
      klass.extend(self)

      class << klass
        def pool(pool_name)
          @pool_name = pool_name
        end
      end
    end

    def with_connection(pool_name: nil, &block)
      retryable(sleep: 0.5) do
        connection_pool(pool_name: pool_name).with &block
      end
    end

    def connection_pool(pool_name: nil)
      Bellbro::Settings.connection_pools[pool_name || @pool_name]
    end
  end

end