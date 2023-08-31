require "./_base"

class AI::MxNode
  include MtNode

  getter list : Array(MtNode)
  getter _ord : Array(Int32)? = nil

  def initialize(@list, @cpos, @_idx, @_ord = nil)
    @zstr = @list.join(&.zstr)
    # pp [@zstr, "mx:#{cpos}"]
  end

  def translate!(dict : MtDict) : Nil
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
    else
      @list.each(&.translate!(dict))
    end
  end

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
