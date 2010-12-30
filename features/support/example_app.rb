class ExampleApp
  def self.build
    ::Rack::Builder.app do
      use Lackie::Rack::Middleware
      use Rack::Static, :urls => ["/example_app"], :root => File.dirname(__FILE__)
      run lambda { |e| [404, {'Content-Type' => 'text/html'}, ['Not Found']] }
    end
  end
end