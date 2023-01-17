require "../../server"
require "./views/*"
require "../models/*"

abstract class AC::Base
  # add helpers here
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
