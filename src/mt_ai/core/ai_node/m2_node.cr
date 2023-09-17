require "./ai_node"

class MT::M2Node
  include AiNode

  getter left : AiNode
  getter right : AiNode

  @flip = false

  def initialize(@left, @right, @cpos, @_idx, @attr = :none, @ipos = MtCpos[cpos])
    @zstr = "#{@left.zstr}#{@right.zstr}"
  end

  def translate!(dict : AiDict, rearrange : Bool = true) : Nil
    self.tl_whole!(dict: dict)
    {@left, @right}.each(&.translate!(dict, rearrange: rearrange))
    self.rearrange!(dict) if rearrange
  end

  private def rearrange!(dict : AiDict) : Nil
    case @ipos
    when MtCpos["DVP"] then fix_dvp!
    when MtCpos["DNP"] then fix_dnp!
    when MtCpos["LCP"] then fix_lcp!
    when MtCpos["VRD"] then fix_vrd!
    when MtCpos["VCD"] then fix_vcd!
    when MtCpos["VCP"] then fix_vcp!
    when MtCpos::QP    then fix_qp!
    when MtCpos["DP"]
      @flip = !@left.attr.at_h?
    end
  end

  def fix_lcp!
    @flip = !right.attr.at_t?
  end

  def fix_dvp!
    # TODO
    # pp [left, right]
  end

  def fix_dnp!
    if @left.attr.at_h?
      @attr = :at_h
      return
    end

    @flip = true
    return unless right.zstr == "的" && right.cpos == "DEG"

    if not_ktetic?(left)
      right.set_term!(MtTerm.new("", MtAttr[:hide, :at_t]))
    else
      right.set_vstr!("của")
      right.off_attr!(:hide)
    end
  end

  def fix_qp!
    @flip = @left.ipos == MtCpos::OD || @right.zstr.includes?('之')
  end

  private def not_ktetic?(node : AiNode)
    return true if node.attr.includes?(MtAttr[Ndes, Ntmp])
    return false if node.attr.includes?(MtAttr[Nper, Norg, Nloc])

    while node.ipos == MtCpos::NP
      node = node.last
    end

    return node.attr.nper? if node.ipos == MtCpos::PN
    node.attr.includes?(MtAttr[Ndes, Ntmp]) || !node.cpos.in?("NP", "NR")
  end

  def fix_vcd!
    MtPair.vcd_pair.fix_if_match!(@right, @left, MtStem.verb_stem(@left.zstr))
  end

  def fix_vcp!
    MtPair.vcp_pair.fix_if_match!(@right, @left, MtStem.verb_stem(@left.zstr))
  end

  def fix_vrd!
    @left.find_by_ipos(MtCpos::AS).try(&.add_attr!(MtAttr[Asis, Hide]))
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
