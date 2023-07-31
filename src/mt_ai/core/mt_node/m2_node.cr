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
    end
  end

  def each(&)
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

  def fix_dvp!
    # TODO
    # pp [left, right]
  end

  def fix_dnp!
    # pp [left, right]
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
    when "NP", "NR" then true
    when "NN"       then !node.attr.includes?("ATTR") # TODO: add ATTR to node
    else                 false
    end
  end
end
