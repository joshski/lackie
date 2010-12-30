Lackie
======
Warning
-------
I haven't used Lackie to develop an application yet. But I have used it in
various browsers including firefox, chrome and the samsung maple emulator.

About
-----
Lackie enables automation of remote applications using an HTTP middleman:
<pre>
  Ruby Client -> Lackie Service <- Remote App
</pre>

Lackie automates applications running in environments that are difficult to
control remotely. Lackie requires minimal support in target environments:
scheduling (e.g. window.setInterval) and HTTP client capabilities (e.g. ajax).

Where it's difficult to programmatically launch the remote application, it can
be started manually before the automation begins. Lackie effectively "attaches"
itself to the running "zombie" application.

Lackie uses an HTTP service as a proxy for application automation commands:

  1. application surrenders control to automation
  2. the surrendered application polls Lackie for commands
  3. the automator sends a command to Lackie
  4. the application executes the command and sends the result to Lackie
  5. the automator polls Lackie and receives the result (or error)

Usage
-----

Lackie is implemented as rack middleware, so:

<pre>
  require 'rack'
  require 'lackie'
  require 'lackie/rack'
  
  Rack::Builder.app do
    use Lackie::Rack::Middleware
    run MyApp
  end
</pre>
  
It will intercept all requests where the path starts with /lackie/

Lackie expects remote applications to:

  1. poll the middleware for commands expressed as strings
  2. execute those commands when they appear
  3. send string results back to the middleware

Example
-------
The source code includes an example rack app:
<pre>
  rackup features/support/config.ru
</pre>
Open this URL in your browser of choice:
<pre>
  http://localhost:9292/example_app/app.html
</pre>
Now you can execute commands in the remote application:
<pre>
  require 'rubygems'
  require 'lackie'
  Lackie::RemoteControl.new("localhost", 9292).exec("1 + 2") # => "3"
</pre>