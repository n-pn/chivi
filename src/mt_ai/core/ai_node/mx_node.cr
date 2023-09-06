require "./ai_node"

class MT::MxNode
  include AiNode

  getter list : Array(AiNode)
  getter _ord : Array(Int32)? = nil

  def initialize(@list, @cpos, @_idx, @prop = :none)
    @zstr = @list.join(&.zstr)
  end

  @[AlwaysInline]
  def tl_phrase!(dict : AiDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_term!(*found)
    else
      @list.each(&.tl_phrase!(dict))
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict) : Nil
    @list.each(&.tl_word!(dict))
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
