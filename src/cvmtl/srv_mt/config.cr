require "../../config"

require "action-controller"
require "action-controller/logger"
require "action-controller/server"

module MT
  Log = ::Log.for("cvmtl")

  ActionController::Server.before(
    ActionController::ErrorHandler.new,
    ActionController::LogHandler.new(["X-Request-ID"]),
  )
end
