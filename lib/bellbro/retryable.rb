module Bellbro
  module Retryable
    def self.included(klass)
      klass.extend(self)
    end

    # Options:
    # * :tries - Number of retries to perform. Defaults to 1.
    # * :on - The Exception on which a retry will be performed. Defaults to Exception, which retries on any Exception.
    #
    # Example
    # =======
    #   retryable(:tries => 1, :on => OpenURI::HTTPError) do
    #     # your code here
    #   end
    #

    def retryable(options = {}, &block)
      opts = { :tries => 5, :on => Exception, :sleep => 1 }.merge(options)
      retry_exception, retries, interval = opts[:on], opts[:tries], opts[:sleep]

      begin
        return yield
      rescue retry_exception
        sleep interval
        retry unless (retries -= 1).zero?
      end
      yield
    end

    def retryable_with_success(options = {}, &block)
      opts = { :tries => 5, :on => Exception, :sleep => 1 }.merge(options)
      retry_exception, retries, interval = opts[:on], opts[:tries], opts[:sleep]

      success = false
      begin
        yield
        success = true
      rescue retry_exception
        sleep interval
        retry unless (retries -= 1).zero?
      end
      success
    end

    def retryable_with_aws(options = {}, &block)
      # This is for use with AWS-based models. I find I get a lot of these timeouts and
      # OpenSSL errors, and sometimes the connection dies and I need to create a new
      # connection object. I put this in a method called aws_connect!.
      #
      opts = { :tries => 10, :on => Exception, :sleep => 1 }.merge(options)
      retry_exception, retries, interval = opts[:on], opts[:tries], opts[:sleep]

      begin
        return yield
      rescue OpenSSL::SSL::SSLError, Timeout::Error
        sleep interval
        aws_connect!
        retry unless (retries -= 1).zero?
      rescue retry_exception
        sleep interval
        retry unless (retries -= 1).zero?
      end
      yield
    end
  end
end