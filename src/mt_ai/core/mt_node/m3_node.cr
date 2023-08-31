require "./_base"

class AI::M3Node
  include MtNode

  getter left : MtNode
  getter middle : MtNode
  getter right : MtNode

  def initialize(@left, @middle, @right, @cpos, @_idx)
    @zstr = "#{@left.zstr}#{@middle.zstr}#{@right.zstr}"
  end

  def translate!(dict : MtDict) : Nil
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
      return
    end

    {@left, @middle, @right}.each(&.translate!(dict))
  end

  def tl_phrase!(dict : MtDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
    else
      {@left, @middle, @right}.each(&.tl_phrase!(dict))
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : MtDict)
    {@left, @middle, @right}.each(&.tl_word!(dict))
  end

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

  def last
    @right
  end
end
