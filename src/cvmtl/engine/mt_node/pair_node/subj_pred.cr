require "./pair_node"

class MT::SubjPred < MT::PairNode
  include MtList

  def initialize(head : MtNode, tail : MtNode, tag : MtlTag = MtlTag::SubjVerb)
    pos = tail.pos.desire? ? MtlPos::Desire : MtlPos::None
    super(head, tail, tag: tag, pos: pos)
  end

  def add_objt(objt : MtNode) : Nil
    # puts [objt, tail, "add_objt"]
    self.fix_succ!(objt.succ?)
    objt.fix_succ!(nil)

    tail = @tail
    tail = tail.tail if tail.is_a?(VerbPair)
    tail = VerbForm.new(tail) unless tail.is_a?(VerbForm)

    tail.add_objt(objt)
  end

  def add_verb(verb : MtNode) : Nil
    self.fix_succ!(verb.succ?)
    verb.fix_succ!(nil)

    @tail = VerbPair.new(@tail, verb)
  end
end
