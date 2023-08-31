require "./_base"

class AI::M1Node
  include MtNode

  getter node : MtNode

  def initialize(@node, @cpos, @_idx)
    @zstr = node.zstr
  end

  def tl_phrase!(dict : MtDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
    else
      node.tl_phrase!(dict: dict)
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : MtDict)
    @node.tl_word!(dict)
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
