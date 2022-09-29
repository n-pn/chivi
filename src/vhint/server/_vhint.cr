require "action-controller"
require "action-controller/logger"
require "action-controller/server"

module VH::Server
  Log         = ::Log.for("vhint")
  LOG_BACKEND = ActionController.default_backend

  ::Log.builder.bind "action-controller.*", :warn, LOG_BACKEND
  ::Log.builder.bind "vhint.*", :warn, LOG_BACKEND
end

abstract class YS::BaseCtrl < ActionController::Base
  add_responder("*/*") { |io, result| io << result }
  add_responder("text/html") { |io, result| result.to_json(io) }
  add_responder("text/plain") { |io, result| io << result }
end
