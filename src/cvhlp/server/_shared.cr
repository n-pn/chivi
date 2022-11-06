require "action-controller"
require "action-controller/logger"
require "action-controller/server"

module TL::Server
  Log         = ::Log.for("libmt")
  LOG_BACKEND = ActionController.default_backend

  ::Log.builder.bind "action-controller.*", :warn, LOG_BACKEND
  ::Log.builder.bind "libmt.*", :warn, LOG_BACKEND
end

abstract class TL::BaseCtrl < ActionController::Base
  add_responder("aplication/json") { |io, result| result.to_json(io) }
  add_responder("text/plain") { |io, result| io << result }
end
