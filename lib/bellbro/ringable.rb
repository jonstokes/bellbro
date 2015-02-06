module Bellbro
  module Ringable
    def self.included(klass)
      klass.extend(self)
    end

    def ring(logline, opts={})
      domain_insert = @domain ? "[#{@domain}]": ""
      error_insert = (opts[:type] == :error) ? "##ERROR## " : ""
      complete_logline = "[#{self.class}](#{Thread.current.object_id})#{domain_insert}: #{error_insert}#{logline}"
      Bellbro.logger.info complete_logline
    end
  end
end