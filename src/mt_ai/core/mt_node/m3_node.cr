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
