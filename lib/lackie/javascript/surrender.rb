module Lackie
  module JavaScript
    class Surrender
      def script
        @@script ||= file("json2.js") + "\n" + file("surrender.js")
      end
      
      private
      
      def file(name)
        File.read(File.join(File.dirname(__FILE__), name))
      end
    end
  end
end