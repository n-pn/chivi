require "./ai_node"

class MT::VpNode
  include AiNode

  getter orig = [] of AiNode
  getter data = [] of AiNode

  def initialize(@orig, @cpos, @_idx)
    @zstr = orig.join(&.zstr)
  end

  def tl_phrase!(dict : AiDict) : Nil
    if found = dict.get?(@zstr, @cpos)
      self.set_term!(*found)
    else
      @orig.each(&.tl_phrase!(dict))
      @data = AiRule.read_vp!(dict, orig)
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict) : Nil
    @orig.each(&.tl_word!(dict))
    @data = AiRule.read_vp!(dict, orig)
  end

  ###

  def z_each(&)
    @orig.each { |node| yield node }
  end

  def v_each(&)
    list = @data.empty? ? @orig : @data
    list.each { |node| yield node }
  end

  def first
    @orig.first
  end

  def last
    @orig.last
  end
end
