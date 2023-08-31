require "./_base"

class AI::VpNode
  include MtNode

  getter orig = [] of MtNode
  getter data = [] of MtNode

  def initialize(@orig, @cpos, @_idx)
    @zstr = orig.join(&.zstr)
  end

  def translate!(dict : MtDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
      return
    end

    @orig.each(&.translate!(dict))
    # TODO: flip elements order accordingingly
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
