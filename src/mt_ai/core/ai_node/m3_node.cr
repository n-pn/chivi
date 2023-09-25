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
      @rhsn.set_vstr!(vstr: "nổi") if @rhsn.zstr == "住"
    when .vnv?
      fix_vnv! if @lhsn.zstr == @rhsn.zstr
    end
  end

  def fix_vnv!
    AiRule.fix_vnv_lhs!(@lhsn)

    case @midn.zstr
    when "没", "不"
      @midn.set_vstr!("không")
      @rhsn.set_vstr!("hay")
      @midn, @rhsn = @rhsn, @midn
    when "一"
      @midn.set_vstr!("thử")
    end
  end

  def z_each(&)
    [lhsn, midn, rhsn].sort_by(&._idx).each { |node| yield node }
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
