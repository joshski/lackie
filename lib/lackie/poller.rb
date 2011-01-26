module Lackie
  class Poller
    def initialize(options={})
      @timeout_seconds = options.delete(:timeout_seconds) || 3
      @interval_seconds = options.delete(:interval_seconds) || 0.2
      @sleeper = options.delete(:sleeper) || Kernel
    end
    
    def await(outcome, options={})
      seconds_waited = 0
      timeout_seconds = options[:timeout_seconds] || @timeout_seconds
      while seconds_waited <= timeout_seconds
        return if yield
        @sleeper.sleep @interval_seconds
        seconds_waited += @interval_seconds
      end
      raise TimeoutError.new("Timed out after #{timeout_seconds} seconds awaiting #{outcome}")
    end
  end
  
  class TimeoutError < RuntimeError
  end
end