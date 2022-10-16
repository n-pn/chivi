require "../node_expr/base_expr"

class MT::VerbForm < MT::MtNode
  include BaseExpr

  property advb_head : MtNode? = nil
  property prep_head : MtNode? = nil

  property auxi : MtNode? = nil
  property verb : MtNode
  property cmpl : MtNode? = nil # complement
  property objt : MtNode? = nil

  property prep_tail : MtNode? = nil
  property advb_tail : MtNode? = nil

  # property tail : MtNode? = nil # put after objects

  forward_missing_to @verb

  def initialize(@verb, @tag = verb.tag)
    self.fix_prev!(@verb.prev?)
    self.fix_succ!(@verb.succ?)
  end

  def add_head(head : MtNode)
    self.fix_prev!(head.prev?)
    head.fix_prev!(nil)

    case head
    when .prep_form?
      add_prep(head)
    when .vauxil?
      add_auxi(head)
    else
      add_advb(head)
    end
  end

  private def add_auxi(auxi : MtNode)
    # TODO: fix auxi val here?

    if prev = @auxi
      tag = MtlTag::Vmod
      pos = auxi.pos | prev.pos
      @auxi = PairNode.new(auxi, prev, tag, pos)
    else
      @auxi = auxi
    end
  end

  private def add_advb(advb : MtNode)
    tag, pos = PosTag::DvPhrase

    if advb.at_tail?
      if node = @advb_tail
        @advb_tail = PairNode.new(advb, node, tag, pos, flip: true)
      else
        @advb_tail = advb
      end
    else
      if node = @advb_head
        @advb_head = PairNode.new(advb, node, tag, pos, flip: false)
      else
        @advb_head = advb
      end
    end
  end

  private def add_prep(prep : MtNode)
    tag, pos = PosTag::PrepForm

    if prep.at_tail?
      if node = @prep_tail
        @prep_tail = PairNode.new(prep, node, tag, pos, flip: true)
      else
        @prep_tail = prep
      end
    else
      if node = @prep_head
        @prep_head = PairNode.new(prep, node, tag, pos, flip: false)
      else
        @prep_head = prep
      end
    end
  end

  def add_objt(@objt : MtNode) : Nil
    self.tag = MtlTag::Vobj
    self.fix_succ!(objt.succ?)
    objt.fix_succ!(nil)
  end

  def each
    @advb_head.try { |x| yield x }

    @auxi.try { |x| yield x }
    @prep_head.try { |x| yield x }

    yield verb

    @cmpl.try { |x| yield x }
    @objt.try { |x| yield x }

    @prep_tail.try { |x| yield x }
    @advb_tail.try { |x| yield x }
  end

  def need_obj? : Bool
    !(@objt || @verb.tag.verb_no_obj? || @succ.tag.object?)
  end
end
