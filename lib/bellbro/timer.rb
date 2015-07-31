module Bellbro
  class Timer
    attr_reader :limit, :started

    def initialize(limit=nil)
      @limit ||= 1.hour
      @started = Time.current
    end

    def timed_out?
      Time.current - started > limit
    end
  end
end
