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
    end
  end

  def fix_lcp!
    @flip = true # unless ???
  end

  def fix_dvp!
    # TODO
    # pp [left, right]
  end

  def fix_dnp!
    @flip = true

    if ktetic?(left)
      right.set_term!(MtTerm.new("của"))
      # else
      # right.set_term!(MtTerm.new("", MtPecs[:void, :post]))
    end
  end

  private def ktetic?(node : AiNode)
    while node.cpos == "NP"
      # NOTE: remove recursion here?
      node = node.last
    end

    case node.cpos
    when "NP", "NR", "PN"
      true
    when "NN", "NT"
      !node.term.try(&.pecs.nadj?)
    else
      false
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

  def last
    @right
  end
end
