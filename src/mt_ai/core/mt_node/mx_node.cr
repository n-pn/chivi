require "./_base"

class AI::MxNode
  include MtNode

  getter list : Array(MtNode)

  def initialize(@list, @ptag, @attr, @_idx)
  end

  def each(&)
    @list.each { |node| yield node }
  end

  def last
    @list.last
  end
end
