require "./ai_node"

class MT::M3Node
  include AiNode

  getter lhsn : AiNode
  getter midn : AiNode
  getter rhsn : AiNode

  def initialize(@lhsn, @midn, @rhsn, @epos, @attr = :none, @_idx = lhsn._idx)
    @zstr = {lhsn, midn, rhsn}.join(&.zstr)
  end

  def translate!(dict : AiDict, rearrange : Bool = true)
    self.tl_whole!(dict: dict)
    {@lhsn, @midn, @rhsn}.each(&.translate!(dict, rearrange: rearrange))
    self.rearrange!(dict) if rearrange
  end

  private def rearrange!(dict : AiDict) : Nil
    case @epos
    when .vpt?
      return unless @rhsn.zstr == "住"
      @rhsn.set_vstr!(vstr: "nổi")
    when .vnv?
      return unless @lhsn.zstr == @rhsn.zstr
      # if vstr = MAP_VND_INFIX[@midn.zstr]?
      #   @midn.set_vstr!(vstr: vstr)
      # end
    end
  end

  # MAP_VND_INFIX = {
  #   "一" => "chút",
  # }

  ###

  def z_each(&)
    yield lhsn
    yield midn
    yield rhsn
  end

  def v_each(&)
    yield lhsn
    yield midn
    yield rhsn
  end

  def first
    @lhsn
  end

  def last
    @rhsn
  end
end
