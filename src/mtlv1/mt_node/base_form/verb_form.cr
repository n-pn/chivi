require "../base_node"

class CV::VerbForm < CV::BaseNode
  include BaseExpr

  property advb : BaseNode? = nil
  property verb : BaseNode
  property cmpl : BaseNode? = nil # complement
  property dobj : BaseNode? = nil
  property tail : BaseNode? = nil # put after objects

  forward_missing_to @verb

  def initialize(@verb, @tag = verb.tag)
    self.fix_prev!(@verb.prev?)
    self.fix_succ!(@verb.succ?)
  end

  def add_advb(advb : BaseNode)
    self.fix_prev!(advb.prev?)
    if prev_advb = @advb
      @advb = BasePair.new(advb, prev_advb, tag: PosTag::DvPhrase, dic: 8)
    else
      @advb = advb
    end
  end

  def add_tail(tail : BaseNode)
    self.fix_prev!(tail.prev?)

    if prev_tail = @tail
      @tail = BasePair.new(tail, prev_tail, tag: PosTag::DvPhrase, dic: 8, flip: true)
    else
      @tail = tail
    end
  end

  def add_prep(prep_form : BaseNode)
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
