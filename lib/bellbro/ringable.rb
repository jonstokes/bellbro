module Bellbro
  module Ringable
    def self.included(klass)
      klass.extend(self)
    end
    
    def gong(log_line)
      ring(log_line, type: :error)
    end

    def ring(log_line, opts={})
      domain_insert = @domain ? "[#{@domain}]": ""
      error_insert = (opts[:type] == :error) ? "PlatformError " : ""
      complete_log_line = "[#{self.class}](#{Thread.current.object_id})#{domain_insert}: #{error_insert}#{log_line}"
      Bellbro.logger.info complete_log_line
    end
  end
end