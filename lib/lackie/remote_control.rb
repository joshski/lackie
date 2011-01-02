require 'restclient'
require 'json'
require 'lackie/poller'

module Lackie
  class RemoteControl
    def initialize(host, port, poller=Poller.new)
      @host, @port, @poller = host, port, poller
    end
    
    def log(message)
      exec("Lackie.log(#{message.to_json})")
    end
    
    def exec(command)
      send_command(command)
      poll_for_result(command)
    end
    
    private
    
    def send_command(command)
      RestClient.post("http://#{@host}:#{@port}/lackie/eval", command)
    end
    
    def poll_for_result(command)
      body = nil
      @poller.await("result of command:\n#{command}") do
        body = retrieve_result_body
        !body.nil?
      end
      parse_result(body)
    end
    
    def retrieve_result_body
      begin
        RestClient.get("http://#{@host}:#{@port}/lackie/result").body
      rescue RestClient::ResourceNotFound
        nil
      end
    end
    
    def parse_result(body)
      parsed_body = JSON.parse(body)
      raise RemoteExecutionError.new(parsed_body["error"]) if parsed_body.include?("error")
      return parsed_body["value"]
    end
  end
  
  class RemoteExecutionError < RuntimeError
  end
end