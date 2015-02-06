module Bellbro
  class Bell
    include Bellbro::Retryable
    include Bellbro::Notifier
  end
end

