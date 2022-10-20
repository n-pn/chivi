require "../mt_list"

class MT::VerbCons < MT::MtNode
  include MtList

  property hd_advb : MtNode? = nil
  property hd_prep : MtNode? = nil

  property auxi : MtNode? = nil # auxiliary
  property verb : MtNode        # central verb
  property cmpl : MtNode? = nil # complement
  property objt : MtNode? = nil # object

  property tl_prep : MtNode? = nil
  property tl_advb : MtNode? = nil

  # property tail : MtNode? = nil # put after objects

  forward_missing_to @verb

  def initialize(@verb, @tag = verb.tag, @pos = verb.pos)
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
      if node = @tl_advb
        @tl_advb = PairNode.new(advb, node, tag, pos, flip: true)
      else
        @tl_advb = advb
      end
    else
      if node = @hd_advb
        @hd_advb = PairNode.new(advb, node, tag, pos, flip: false)
      else
        @hd_advb = advb
      end
    end
  end

  private def add_prep(prep : MtNode)
    tag, pos = PosTag::PrepForm

    if prep.at_tail?
      if node = @tl_prep
        @tl_prep = PairNode.new(prep, node, tag, pos, flip: true)
      else
        @tl_prep = prep
      end
    else
      if node = @hd_prep
        @hd_prep = PairNode.new(prep, node, tag, pos, flip: false)
      else
        @hd_prep = prep
      end
    end
  end

  def add_objt(@objt : MtNode) : Nil
    self.tag = MtlTag::Vobj
    self.fix_succ!(objt.succ?)
    objt.fix_succ!(nil)
  end

  def each
    @hd_advb.try { |x| yield x }

    @auxi.try { |x| yield x }
    @hd_prep.try { |x| yield x }

    yield verb

    @cmpl.try { |x| yield x }
    @objt.try { |x| yield x }

    @tl_prep.try { |x| yield x }
    @tl_advb.try { |x| yield x }
  end

  def need_obj? : Bool
    !(@objt || @verb.tag.verb_no_obj? || @succ.tag.object?)
  end
end
