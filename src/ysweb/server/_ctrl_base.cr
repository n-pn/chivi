require "action-controller"
require "action-controller/logger"
require "action-controller/server"

module YS::Server
  Log         = ::Log.for("ysweb")
  LOG_BACKEND = ActionController.default_backend

  ::Log.builder.bind "action-controller.*", :warn, LOG_BACKEND
  ::Log.builder.bind "ysweb.*", :warn, LOG_BACKEND
end

abstract class YS::BaseCtrl < ActionController::Base
  add_responder("*/*") { |io, result| io << result }
  add_responder("text/html") { |io, result| result.to_json(io) }
  add_responder("text/plain") { |io, result| io << result }
end

module YS::CtrlUtil
  extend self

  def page_params(params, max_limit : Int32 = 24)
    if page = params["page"]?.try(&.to_i?)
      pgidx = page > 1 ? page &- 1 : 0
    else
      pgidx = 0
    end

    if take = params["take"]?.try(&.to_i)
      limit = take > max_limit ? max_limit : (take < 0 ? max_limit // 2 : take)
    else
      limit = max_limit // 2
    end

    offset = pgidx &* limit

    {pgidx, limit, offset}
  end

  def pgmax(total : Int, limit : Int)
    (total &- 1) // limit &+ 1
  end
end
