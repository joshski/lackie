require 'lackie/javascript'
require 'lackie/rack/logger'

module Lackie
  module Rack
    class Middleware
      def initialize(app, logger=NilLogger.new)
        @app, @logger = app, logger
        @command = nil
        @result = nil
        @surrender = Lackie::JavaScript::Surrender.new
        @command_id = 0
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
        @logger.log("surrendered to #{request.user_agent}")
        js(@surrender.script)
      end
      
      def eval(request)
        @result = nil
        @command = request.body.read.to_s
        @command_id += 1
        @logger.log("eval " + command_json(@command))
        plain("OK")
      end
      
      def yield(request)
        if @command.nil?
          not_found
        else
          cmd = @command
          @command = nil
          js(command_json(cmd))
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
      
      def command_json(cmd)
        { :command => cmd, :id => @command_id }.to_json
      end
      
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
          r = JSON.parse(request.body.read.to_s)
        rescue
          return bad_request
        end
        if r['id'].to_i == @command_id
          @result = r.to_json
          @logger.log("result #{@result}")
        end
        plain("OK")
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