require "./_base"

class AI::M2Node
  include MtNode

  getter left : MtNode
  getter right : MtNode

  @flip = false

  def initialize(@left, @right, @cpos, @_idx)
    @zstr = "#{@left.zstr}#{@right.zstr}"
  end

  def translate!(dict : MtDict) : Nil
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
      return
    end

    @left.translate!(dict)
    @right.translate!(dict)

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
    @pecs |= :post
    @flip = true
    right.set_tl!("của", pecs: :none) if ktetic?(left)
  end

  private def ktetic?(node : MtNode)
    while node.cpos == "NP"
      # NOTE: remove recursion here?
      node = node.last
    end

    case node.cpos
    when "NP", "NR", "PN"
      true
    when "NN", "NT"
      !node.pecs.nadj?
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
