require "./ai_node"

class MT::M3Node
  include AiNode

  getter left : AiNode
  getter middle : AiNode
  getter right : AiNode

  def initialize(@left, @middle, @right, @cpos, @_idx = left._idx, @attr = :none, @ipos = MtCpos[cpos])
    @zstr = "#{left.zstr}#{middle.zstr}#{right.zstr}"
  end

  def translate!(dict : AiDict, rearrange : Bool = true)
    self.tl_whole!(dict: dict)
    {@left, @middle, @right}.each(&.translate!(dict, rearrange: rearrange))
    self.rearrange!(dict) if rearrange
  end

  private def rearrange!(dict : AiDict) : Nil
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
