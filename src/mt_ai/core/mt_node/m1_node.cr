require "./_base"

class AI::M1Node
  include MtNode

  getter node : MtNode

  def initialize(@node, @cpos, @_idx)
    @zstr = node.zstr
  end

  def translate!(dict : MtDict)
    if found = dict.get?(@zstr, @cpos)
      # pp [found, "m1_tl"]
      self.set_tl!(found)
    else
      @node.translate!(dict)
    end
  end

  ###

  def z_each(&)
    yield @node
  end

  def v_each(&)
    yield @node
  end

  def last
    node
  end
end
