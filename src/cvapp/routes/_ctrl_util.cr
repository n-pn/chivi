require "../../_util/hash_util"

module CV::CtrlUtil
  extend self

  def pg_no(index : Int, limit : Int)
    (index &- 1) // limit &+ 1
  end

  def offset(pgidx : Int32, limit : Int32)
    (pgidx &- 1) &* limit
  end
end
