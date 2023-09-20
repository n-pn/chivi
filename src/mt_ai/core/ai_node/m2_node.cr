require "./ai_node"

class MT::M2Node
  include AiNode

  getter lhsn : AiNode
  getter rhsn : AiNode

  getter flip = false

  def initialize(@lhsn, @rhsn, @epos, @attr = :none, @flip = false, @_idx = lhsn._idx)
    @zstr = {lhsn, rhsn}.join(&.zstr)
  end

  def translate!(dict : AiDict, rearrange : Bool = true) : Nil
    self.tl_whole!(dict: dict)
    {@lhsn, @rhsn}.each(&.translate!(dict, rearrange: rearrange))
    self.rearrange!(dict) if rearrange
  end

  private def rearrange!(dict : AiDict) : Nil
    case @epos
    when .dnp? then fix_dnp!
    when .dvp? then fix_dvp!
    when .lcp? then fix_lcp!
    when .vrd? then fix_vrd!
    when .vcd? then fix_vcd!
    when .vcp? then fix_vcp!
    when .qp?  then fix_qp!
    when .dp?  then @flip = !@lhsn.attr.at_h?
    end
  end

  def fix_lcp!
    @flip = !rhsn.attr.at_t?
  end

  def fix_dvp!
    # TODO
    # pp [lhsn, rhsn]
  end

  def fix_dnp!
    if @lhsn.attr.at_h?
      @attr = :at_h
      return
    end

    @flip = true
    return unless rhsn.zstr == "的" && rhsn.epos.deg?

    if possestive?(lhsn)
      rhsn.set_vstr!("của")
      rhsn.off_attr!(:hide)
    else
      rhsn.set_term!(MtTerm.new("", attr: MtAttr[Hide, At_t]))
    end
  end

  def fix_qp!
    @flip = @lhsn.epos.od? || @rhsn.zstr.includes?('之')
  end

  private def possestive?(node : AiNode)
    while true
      return false if node.attr & MtAttr[Ndes, Ntmp] != MtAttr::None
      return true if node.attr & MtAttr[Nper, Norg, Nloc] != MtAttr::None

      case node.epos
      when .np?
        return true if node.is_a?(M0Node)
        node = node.last
      when .nn?
        return node.attr.nper?
      else
        return node.epos.nn?
      end
    end

    false
  end

  def fix_vcd!
    MtPair.vcd_pair.fix_if_match!(@rhsn, @lhsn, MtStem.verb_stem(@lhsn.zstr))
  end

  def fix_vcp!
    MtPair.vcp_pair.fix_if_match!(@rhsn, @lhsn, MtStem.verb_stem(@lhsn.zstr))
  end

  def fix_vrd!
    @lhsn.find_by_epos(MtEpos::AS).try(&.add_attr!(MtAttr[Asis, Hide]))
    MtPair.vrd_pair.fix_if_match!(@rhsn, @lhsn, MtStem.verb_stem(@lhsn.zstr))
  end

  ###

  def z_each(&)
    yield lhsn
    yield rhsn
  end

  def v_each(&)
    if @flip
      yield rhsn
      yield lhsn
    else
      yield lhsn
      yield rhsn
    end
  end

  def first
    @lhsn
  end

  def last
    @rhsn
  end
end
