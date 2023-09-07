require "./ai_node"

class MT::M2Node
  include AiNode

  getter left : AiNode
  getter right : AiNode

  @flip = false

  def initialize(@left, @right, @cpos, @_idx, @prop = :none)
    @zstr = "#{@left.zstr}#{@right.zstr}"
  end

  def tl_phrase!(dict : AiDict) : Nil
    if found = dict.get?(@zstr, @cpos)
      self.set_term!(*found)
    else
      {@left, @right}.each(&.tl_phrase!(dict))
      fix_inner!(dict)
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict)
    {@left, @right}.each(&.tl_word!(dict))
    fix_inner!(dict)
  end

  @[AlwaysInline]
  private def fix_inner!(dict : AiDict) : Nil
    case @cpos
    when "DVP" then fix_dvp!
    when "DNP" then fix_dnp!
    when "LCP" then fix_lcp!
    when "VRD" then fix_vrd!
    when "VCD" then fix_vcd!
    when "VCP" then fix_vcp!
    when "DP"
      @flip = !@left.prop.at_h?
    when "QP"
      @flip = @left.cpos == "OD"
    end
  end

  def fix_lcp!
    @flip = !right.prop.at_t?
  end

  def fix_dvp!
    # TODO
    # pp [left, right]
  end

  def fix_dnp!
    if @left.prop.at_h?
      @prop = :at_h
      return
    end

    @flip = true
    return unless right.zstr == "的" && right.cpos == "DEG"

    if possessive?(left)
      right.set_vstr!("của")
      right.off_prop!(:hide)
    else
      right.set_term!(MtTerm.new("", MtProp[:hide, :at_t]))
    end
  end

  private def possessive?(node : AiNode)
    return true if node.prop.npos? || node.prop.nper?
    return false if node.prop.ndes? || node.prop.ntmp?

    while node.cpos == "NP"
      # NOTE: remove recursion here?
      node = node.last
    end

    case node.cpos
    when "NP", "NR" then true
    when "PN"       then node.prop.npos? || node.prop.nper?
    when "NN", "NT" then !node.prop.ndes?
    else                 false
    end
  end

  def fix_vcd!
    MtPair.vcd_pair.fix_if_match!(@right, @left, MtStem.verb_stem(@left.zstr))
  end

  def fix_vcp!
    MtPair.vcp_pair.fix_if_match!(@right, @left, MtStem.verb_stem(@left.zstr))
  end

  def fix_vrd!
    @left.find_by_cpos("AS").try(&.add_prop!(MtProp[Asis, Hide]))
    MtPair.vrd_pair.fix_if_match!(@right, @left, MtStem.verb_stem(@left.zstr))
  end

  ###

  def z_each(&)
    yield left
    yield right
  end

  def v_each(&)
    if @flip
      yield right
      yield left
    else
      yield left
      yield right
    end
  end

  def first
    @left
  end

  def last
    @right
  end
end
