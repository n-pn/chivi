require "./ai_node"

class MT::M3Node
  include AiNode

  getter left : AiNode
  getter middle : AiNode
  getter right : AiNode

  def initialize(@left, @middle, @right, @cpos, @_idx, @prop = :none)
    @zstr = "#{@left.zstr}#{@middle.zstr}#{@right.zstr}"
  end

  def tl_phrase!(dict : AiDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_term!(*found)
    else
      {@left, @middle, @right}.each(&.tl_phrase!(dict))
      fix_inner!(dict)
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict)
    {@left, @middle, @right}.each(&.tl_word!(dict))
    fix_inner!(dict)
  end

  @[AlwaysInline]
  private def fix_inner!(dict : AiDict) : Nil
    case @cpos
    when "VPT"
      return unless @right.zstr == "住"
      @right.set_vstr!(vstr: "nổi")
    when "VNV"
      return unless @left.zstr == @right.zstr
      # if vstr = MAP_VND_INFIX[@middle.zstr]?
      #   @middle.set_vstr!(vstr: vstr)
      # end
    end
  end

  # MAP_VND_INFIX = {
  #   "一" => "chút",
  # }

  ###

  def z_each(&)
    yield left
    yield middle
    yield right
  end

  def v_each(&)
    yield left
    yield middle
    yield right
  end

  def first
    @left
  end

  def last
    @right
  end
end
