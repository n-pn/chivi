require "../config"
require "../appcv/**"
require "./ctrls/**"

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
  settings.secret = CV::Config.jwt_auth_key
  settings.secure = CV::Config.production? # HTTPS only
end

server = AC::Server.new(CV::Config.be_port, "127.0.0.1")

terminate = Proc(Signal, Nil).new do |signal|
  puts " > terminating gracefully"
  spawn { server.close }
  signal.ignore
end

Signal::INT.trap &terminate  # Detect ctr-c to shutdown gracefully
Signal::TERM.trap &terminate # Docker containers use the term signal

server.run do
  puts "[cvapp] listening on #{server.print_addresses}"
end

puts "[cvapp] server terminated"
