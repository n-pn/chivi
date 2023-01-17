require "action-controller"
require "action-controller/logger"
require "action-controller/server"

abstract class SP::BaseCtrl < ActionController::Base
  # add_parser("text/plain") { |_klass, body_io| body_io.gets_to_end }

  # add_responder("aplication/json") { |io, result| result.to_json(io) }
  # add_responder("text/plain") { |io, result| io << result }

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
