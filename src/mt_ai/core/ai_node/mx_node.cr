require "./ai_node"

class MT::MxNode
  include AiNode

  getter list : Array(AiNode)

  def initialize(@list, @epos, @attr = :none, @_idx = list.min_of(&._idx))
    @zstr = list.sort_by(&._idx).join(&.zstr)
  end

  @[AlwaysInline]
  def translate!(dict : AiDict, rearrange : Bool = true)
    self.tl_whole!(dict: dict)
    @list.each(&.translate!(dict, rearrange: rearrange))
  end

  ###

  def z_each(&)
    @list.sort_by(&._idx).each { |node| yield node }
  end

  def v_each(&)
    @list.each { |node| yield node }
  end

  def first
    @list.first
  end

  def last
    @list.last
  end
end
