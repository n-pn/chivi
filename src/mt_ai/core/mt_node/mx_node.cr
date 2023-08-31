require "./_base"

class AI::MxNode
  include MtNode

  getter list : Array(MtNode)
  getter _ord : Array(Int32)? = nil

  def initialize(@list, @cpos, @_idx, @_ord = nil)
    @zstr = @list.join(&.zstr)
  end

  @[AlwaysInline]
  def tl_phrase!(dict : MtDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
    else
      @list.each(&.tl_phrase!(dict))
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : MtDict) : Nil
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

  def last
    @list.last
  end
end
