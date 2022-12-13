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
  add_responder("text/plain") { |io, result| io << result }
end

module YS::CtrlUtil
  extend self

  def page_params(params, max_limit : Int32 = 24)
    pgidx = params["pg"]?.try(&.to_i?) || 1

    if take = params["take"]?.try(&.to_i)
      limit = take > max_limit ? max_limit : take
    else
      limit = max_limit // 2
    end

    {pgidx, limit, (pgidx &- 1) &* limit}
  end

  def pgmax(total : Int, limit : Int)
    (total &- 1) // limit &+ 1
  end
end
