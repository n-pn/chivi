require "./ai_node"

class MT::MxNode
  include AiNode

  getter list : Array(AiNode)
  getter _ord : Array(Int32)? = nil

  def initialize(@list, @cpos, @_idx = list.first._idx, @attr = :none, @ipos = MtCpos[cpos])
    @zstr = list.join(&.zstr)
  end

  @[AlwaysInline]
  def translate!(dict : AiDict, rearrange : Bool = true)
    self.tl_whole!(dict: dict)
    @list.each(&.translate!(dict, rearrange: rearrange))
  end

  ###

  def z_each(&)
    @list.each { |node| yield node }
  end

  def v_each(&)
    if _ord = @_ord
      _ord.each { |_idx| yield @list[_idx] }
    else
      @list.each { |node| yield node }
    end
  end

  def first
    @list.first
  end

  def last
    @list.last
  end
end
