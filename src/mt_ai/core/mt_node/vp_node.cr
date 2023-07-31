require "./_base"

class AI::VpNode
  include MtNode

  getter verb : Array(MtNode)
  getter pref = [] of MtNode
  getter suff = [] of MtNode

  def initialize(@verb, @ptag, @attr, @_idx)
  end

  def each(&)
    pref.each { |node| yield node }
    verb.each { |node| yield node }
    suff.each { |node| yield node }
  end

  def last
    @verb.last
  end
end
