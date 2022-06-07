require "action-controller"

require "./mtlv2/*"

module MtlV2
  NAME = "MtlV2"

  Log         = ::Log.for(NAME)
  LOG_BACKEND = ActionController.default_backend

  ENVIRONMENT = ENV["CV_ENV"]? || "development"

  def self.production?
    ENVIRONMENT == "production"
  end
end

if MtlV2.production?
  log_level = Log::Severity::Info
  ::Log.setup "*", :warn, MtlV2::LOG_BACKEND
else
  log_level = Log::Severity::Debug
  ::Log.setup "*", :info, MtlV2::LOG_BACKEND
end

Log.builder.bind "action-controller.*", log_level, MtlV2::LOG_BACKEND
Log.builder.bind "#{MtlV2::NAME}.*", log_level, MtlV2::LOG_BACKEND

# Filter out sensitive params that shouldn't be logged
filter_params = ["upass", "new_upass"]
keeps_headers = ["X-Request-ID"]

# Add handlers that should run before your application
ActionController::Server.before(
  ActionController::ErrorHandler.new(MtlV2.production?, keeps_headers),
  ActionController::LogHandler.new(filter_params),
  HTTP::CompressHandler.new
)

port = (ENV["MTLV2_PORT"]? || 5502).to_i
host = ENV["MTLV2_HOST"]? || "127.0.0.1"
server = ActionController::Server.new(port, host)

terminate = Proc(Signal, Nil).new do |signal|
  puts " > terminating gracefully"
  spawn { server.close }
  signal.ignore
end

# Detect ctr-c to shutdown gracefully
# Docker containers use the term signal
Signal::INT.trap &terminate
Signal::TERM.trap &terminate

# Start the server
server.run do
  puts "#{MtlV2::NAME} listening on #{server.print_addresses}"
end

# Shutdown message
puts "#{MtlV2::NAME} server terminated\n"
