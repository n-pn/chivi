require "../node_expr/base_expr"

class MT::VerbForm < MT::MtNode
  include BaseExpr

  property advb : MtNode? = nil
  property verb : MtNode
  property cmpl : MtNode? = nil # complement
  property dobj : MtNode? = nil
  property tail : MtNode? = nil # put after objects

  forward_missing_to @verb

  def initialize(@verb, @tag = verb.tag)
    self.fix_prev!(@verb.prev?)
    self.fix_succ!(@verb.succ?)
  end

  def add_advb(advb : MtNode)
    self.fix_prev!(advb.prev?)

    if prev_advb = @advb
      @advb = PairNode.new(advb, prev_advb, tag: PosTag::DvPhrase)
    else
      @advb = advb
    end
  end

  def add_tail(tail : MtNode)
    self.fix_prev!(tail.prev?)

    if prev_tail = @tail
      @tail = PairNode.new(tail, prev_tail, tag: PosTag::DvPhrase, flip: true)
    else
      @tail = tail
    end
  end

  def add_prep(prep_form : MtNode)
    if prep_form.at_tail?
      add_tail(prep_form)
    else
      add_advb(prep_form)
    end
  end

  def each
    @advb.try { |x| yield x }
    yield verb
    @cmpl.try { |x| yield x }
    @dobj.try { |x| yield x }
    @tail.try { |x| yield x }
  end

  def need_obj? : Bool
    !(@dobj || @verb.tag.verb_no_obj? || @succ.tag.object?)
  end
end
