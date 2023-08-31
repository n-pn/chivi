require "./_base"

class AI::VpNode
  include MtNode

  getter data : Array(MtNode)

  def initialize(@data, @cpos, @_idx)
  end

  def z_each(&)
    @data.sort_by(&._idx).each { |node| yield node }
  end

  def v_each(&)
    @data.each { |node| yield node }
  end

  def last
    @data.max_by(&._idx)
  end
end
