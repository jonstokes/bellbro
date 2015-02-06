module Bellbro
  class Bell
    include Bellbro::Retryable
    include Bellbro::Ringer
  end
end

