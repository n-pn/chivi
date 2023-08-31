require "./_base"

class AI::VpNode
  include MtNode

  getter orig = [] of MtNode
  getter data = [] of MtNode

  def initialize(@orig, @cpos, @_idx)
    @zstr = orig.join(&.zstr)
  end

  def tl_phrase!(dict : MtDict) : Nil
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
    else
      @orig.each(&.tl_phrase!(dict))
      fix_inner!(dict)
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : MtDict) : Nil
    @orig.each(&.tl_word!(dict))
    fix_inner!(dict)
  end

  @[AlwaysInline]
  private def fix_inner!(dict : MtDict) : Nil
    # TODO!
  end

  ###

  def z_each(&)
    @orig.each { |node| yield node }
  end

  def v_each(&)
    list = @data.empty? ? @orig : @data
    list.each { |node| yield node }
  end

  def last
    @orig.last
  end
end
