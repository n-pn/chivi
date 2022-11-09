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

  def calc_pgmax(total : Int, limit : Int)
    (total &- 1) // limit &+ 1
  end

  def fix_paged(pgidx : Int32, limit : Int32)
    pgidx = 1 if pgidx < 1
    limit = 50 if limit > 50
    offset = (pgidx - 1) * limit

    {pgidx, limit, offset}
  end
end
