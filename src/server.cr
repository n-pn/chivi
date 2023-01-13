require "./config"

require "action-controller"
require "action-controller/logger"
require "action-controller/server"

# Add handlers that should run before your application
ActionController::Server.before(
  ActionController::ErrorHandler.new(CV::Config.production?, ["X-Request-ID"]),
  ActionController::LogHandler.new(["upass", "new_upass"]),
  HTTP::CompressHandler.new
)

ActionController::Session.configure do |settings|
  settings.key = "_sess"
  settings.secret = CV::Config.session_skey
  settings.secure = CV::Config.production? # HTTPS only
end

def start_server!(port : Int32, server_name = "Chivi")
  server = AC::Server.new(port, "127.0.0.1")

  terminate = Proc(Signal, Nil).new do |signal|
    signal.ignore
    server.close
    # puts " > terminating gracefully"
    # spawn { server.close }
  end

  Signal::INT.trap &terminate  # Detect ctr-c to shutdown gracefully
  Signal::TERM.trap &terminate # Docker containers use the term signal

  server.run do
    puts "[#{server_name}] listening on #{server.print_addresses}"
  end

  puts "[#{server_name}] server terminated"
end
