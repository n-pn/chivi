require "../mt_list"

class MT::VerbCons < MT::MtNode
  include MtList

  property hd_advb : MtNode? = nil
  property hd_prep : MtNode? = nil

  property auxi : MtNode? = nil # auxiliary
  property verb : MtNode        # central verb
  property cmpl : MtNode? = nil # time/frequency complement
  property objt : MtNode? = nil # object

  property tl_prep : MtNode? = nil
  property tl_advb : MtNode? = nil

  # property tail : MtNode? = nil # put after objects

  forward_missing_to @verb

  def initialize(@verb, @tag = verb.tag, @pos = verb.pos)
    self.fix_prev!(@verb.prev?)
    self.fix_succ!(@verb.succ?)
  end

  def add_advb(advb : MtNode)
    add_head(advb)

    tag = MtlTag::Adform
    pos = advb.pos

    if advb.at_tail?
      if node = @tl_advb
        @tl_advb = PairNode.new(advb, node, tag, pos | node.pos, flip: true)
      else
        @tl_advb = advb
      end
    elsif node = @hd_advb
      @hd_advb = PairNode.new(advb, node, tag, pos: pos | node.pos, flip: false)
    else
      @hd_advb = advb
    end
  end

  def add_prep(prep : MtNode)
    add_head(prep)
    tag, pos = PosTag.make(:prep_form)

    if prep.at_tail?
      if node = @tl_prep
        @tl_prep = PairNode.new(prep, node, tag, pos | node.pos, flip: true)
      else
        @tl_prep = prep
      end
    elsif node = @hd_prep
      @hd_prep = PairNode.new(prep, node, tag, pos | node.pos, flip: false)
    else
      @hd_prep = prep
    end
  end

  def add_auxi(auxi : MtNode)
    add_head(auxi)
    # TODO: fix auxi val here?

    if prev = @auxi
      tag = MtlTag::Vmod
      pos = auxi.pos | prev.pos
      @auxi = PairNode.new(auxi, prev, tag, pos)
    else
      @auxi = auxi
    end
  end

  private def add_head(node : MtNode) : Nil
    self.fix_prev!(node.prev?)
    node.fix_prev!(nil)
    node.fix_succ!(nil)
  end

  def add_objt(@objt : MtNode) : Nil
    self.tag = MtlTag::Vobj
    self.fix_succ!(objt.succ?)
    objt.fix_succ!(nil)

    self.fix_aspcmpl_val!(@verb)
  end

  private def fix_aspcmpl_val!(node : MtNode)
    while node.is_a?(PairNode)
      tail = node.tail

      if tail.aspect_marker?
        return tail.as(MonoNode).skipover!
      else
        node = node.head
      end
    end

    node.val = node.val.sub(/ (rồi|lấy)/, "") if node.is_a?(MonoNode)
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
