require "./_base"

class AI::M2Node
  include MtNode

  getter left : MtNode
  getter right : MtNode

  @flip = false

  def initialize(@left, @right, @ptag, @attr, @_idx)
    case ptag
    when "DVP" then fix_dvp!
    when "DNP" then fix_dnp!
    when "LCP" then fix_lcp!
    end
  end

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

  def fix_lcp!
    @flip = true # unless ???
  end

  def fix_dvp!
    # TODO
    # pp [left, right]
  end

  def fix_dnp!
    @attr = "TAIL"
    @flip = true

    if is_ktetic?(left)
      right.ptag = "DEG2"
      right.as(M0Node).term = MtTerm::DEG2
    end
  end

  def is_ktetic?(node : MtNode)
    return true if node.attr.includes?("PN")

    while node.ptag == "NP"
      # NOTE: remove recursion here?
      node = node.last
    end

    case node.ptag
    when "NP", "NR", "PN"
      true
    when "NN"
      !node.attr.includes?("ATTR") # TODO: add ATTR to node
    else
      false
    end
  end
end
