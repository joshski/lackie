module Lackie
  module Rack
    class NilLogger
      def log(message)
      end
    end
    
    class SimpleLogger
      def log(message)
        Kernel.puts message
      end
    end
  end
end