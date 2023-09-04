require "./ai_node"

class MT::M2Node
  include AiNode

  getter left : AiNode
  getter right : AiNode

  @flip = false

  def initialize(@left, @right, @cpos, @_idx)
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
    when "DP"
      @flip = !@left.pecs.at_h?
    when "QP"
      @flip = @left.cpos == "OD"
    end
  end

  def fix_lcp!
    @flip = !right.pecs.at_t?
  end

  def fix_dvp!
    # TODO
    # pp [left, right]
  end

  def fix_dnp!
    @pecs = :at_h if @left.pecs.at_h?
    @flip = true

    if right.cpos == "DEG" && possessive?(left)
      right.set_vstr!("của")
      right.off_pecs!(:void)
      # else
      # right.set_term!(MtTerm.new("", MtPecs[:void, :at_t]))
    end
  end

  private def possessive?(node : AiNode)
    return true if node.pecs.npos? || node.pecs.nper?

    while node.cpos == "NP"
      # NOTE: remove recursion here?
      node = node.last
    end

    case node.cpos
    when "NP", "NR" then true
    when "PN"       then node.pecs.npos? || node.pecs.nper?
    when "NN", "NT" then !node.pecs.ndes?
    else                 false
    end
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
