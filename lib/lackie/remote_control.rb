require 'restclient'
require 'json'
require 'lackie/poller'
require 'lackie/cache_buster'

module Lackie
  class RemoteControl
    def initialize(host, port, poller=Poller.new)
      @host, @port, @poller = host, port, poller
    end
    
    def log(message)
      exec("Lackie.log(#{message.to_json})")
    end
    
    def exec(command, options={})
      send_command(command)
      poll_for_result(command, options)
    end
    
    def await(expression, options={})
      result = nil
      begin
        @poller.await("result matching expression: #{expression}", options) do
          begin
            result = exec(expression)
          rescue TimeoutError => e
          end
          yield result
        end
      rescue TimeoutError => e
        raise AwaitError.new(expression, result)
      end
      result
    end
    
    private

    def send_command(command)
      url = "http://#{@host}:#{@port}/lackie/eval"
      begin
        RestClient.post(url, command)
      rescue => e
        raise ConnectionError.new(url, e) 
      end
    end
    
    def poll_for_result(command, options={})
      body = nil
      @poller.await("result of command:\n#{command}", options) do
        body = retrieve_result_body
        !body.nil?
      end
      parse_result(body)
    end
    
    def retrieve_result_body
      begin
        RestClient.get("http://#{@host}:#{@port}/lackie/result?#{CacheBuster.unique_string}").body
      rescue RestClient::ResourceNotFound
        nil
      end
    end
    
    def parse_result(body)
      parsed_body = JSON.parse(body)
      if parsed_body.include?("error")
        raise RemoteExecutionError.new(parsed_body["error"]) 
      end
      return parsed_body["value"]
    end
  end
  
  class ConnectionError < RuntimeError
    def initialize(url, inner)
      @url, @inner = url, inner
    end
    
    def message
      "Failed to send command to #{@url} - " +
      "have you started a lackie server?\n#{@inner.message}"
    end
  end
  
  class RemoteExecutionError < RuntimeError
  end
  
  class AwaitError < RuntimeError
    def initialize(expression, result)
      @expression, @result = expression, result
    end
    
    def message
      "Timed out awaiting the result of expression:\n" +
      "#{@expression}\n" +
      "The last result was:\n#{@result}"
    end
  end
end