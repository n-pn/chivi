require "action-controller"
require "action-controller/logger"
require "action-controller/server"

module CV::MtlV2
  NAME = "MtlV2"

  Log         = ::Log.for(NAME)
  LOG_BACKEND = ActionController.default_backend

  ENVIRONMENT = ENV["CV_ENV"]? || "development"

  def self.production?
    ENVIRONMENT == "production"
  end

  if production?
    log_level = ::Log::Severity::Info
    ::Log.setup "*", :warn, LOG_BACKEND
  else
    log_level = ::Log::Severity::Debug
    ::Log.setup "*", :info, LOG_BACKEND
  end

  ::Log.builder.bind "action-controller.*", log_level, LOG_BACKEND
  ::Log.builder.bind "#{NAME}.*", log_level, LOG_BACKEND

  # Filter out sensitive params that shouldn't be logged
  filter_params = ["upass", "new_upass"]
  keeps_headers = ["X-Request-ID"]

  # Add handlers that should run before your application
  ActionController::Server.before(
    ActionController::ErrorHandler.new(production?, keeps_headers),
    ActionController::LogHandler.new(filter_params),
    HTTP::CompressHandler.new
  )
end
