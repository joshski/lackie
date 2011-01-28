require 'lackie/javascript'

module Lackie
  module Rack
    class Middleware
      def initialize(app)
        @app = app
        @command = nil
        @result = nil
        @surrender = Lackie::JavaScript::Surrender.new
        @id = 0
      end                

      def call(env)
        request = ::Rack::Request.new(env)
        if request.path.match(/\/lackie\/(.+)$/) and self.respond_to?($1)
          self.send($1, request)
        else
          @app.call(env)
        end
      end
      
      def surrender(request)
        #@result = nil
        js(@surrender.script)
      end
      
      def eval(request)
        @result = nil
        @command = request.body.read.to_s
        plain("OK")
      end
      
      def yield(request)
        if @command.nil?
          not_found
        else
          cmd = @command
          @command = nil
          json = { :command => cmd, :id => @id += 1}.to_json
          js(json)
        end
      end
      
      def result(request)
        if request.get?
          get_result(request)
        else
          set_result(request)
        end
      end
      
      private
      
      def get_result(request)
        if @result.nil?
          not_found
        else
          str = @result
          @result = nil
          json(str)
        end
      end
      
      def set_result(request)
        begin
          @result = JSON.parse(request.body.read.to_s).to_json
          plain("OK")
        rescue
          bad_request
        end
      end
      
      def js(script)
        ok('text/javascript', script)
      end
      
      def json(string)
        ok('application/json', string)
      end
      
      def plain(script)
        ok('text/plain', script)
      end
      
      def ok(content_type, body)
        [200, {'Content-Type' => content_type}, [body]]
      end
      
      def not_found
        [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
      end
      
      def bad_request
        [400, {'Content-Type' => 'text/plain'}, ['Bad Request']]
      end
    end
  end
end