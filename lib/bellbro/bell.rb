module Bellbro
  class Bell
    include Bellbro::Retryable
    include Bellbro::Ringable
  end
end

