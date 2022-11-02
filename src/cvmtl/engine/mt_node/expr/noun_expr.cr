require "../mt_list"

class MT::NounExpr < MT::MtNode
  include MtList

  getter hd_pdmod : MtNode? = nil
  getter hd_nqmod : MtNode? = nil
  getter hd_dpmod : MtNode? = nil

  getter noun : MtNode
  forward_missing_to @noun

  getter tl_dpmod : MtNode? = nil
  getter tl_nqmod : MtNode? = nil
  getter tl_pdmod : MtNode? = nil

  getter hd_locat : MtNode? = nil

  def initialize(@noun, @tag = noun.tag, @pos = noun.pos)
    self.fix_prev!(noun.prev?)
    self.fix_succ!(noun.succ?)
    # noun.fix_prev!(nil)
    # noun.fix_succ!(nil)

    if noun.is_a?(PairNode) && noun.tail.locat_words?
      @noun = noun.head
      @hd_locat = noun.tail
    end
  end

  def add_pdmod(node : MtNode)
    add_head(node)

    if node.at_tail?
      @tl_pdmod = node
    else
      @hd_pdmod = node
    end
  end

  def add_nqmod(node : MtNode) : Nil
    add_head(node)

    if node.at_tail?
      @tl_pdmod = node
    else
      @hd_pdmod = node
    end
  end

  def add_dpmod(node : MtNode)
    add_head(node)

    if node.at_head?
      @hd_dpmod = node
    else
      @tl_dpmod = node
    end
  end

  private def add_head(head : MtNode)
    self.fix_prev!(head.prev?)
    head.fix_prev!(nil)
  end

  def add_locat(locat : MtNode)
    @hd_locat = locat
    self.fix_succ!(locat.succ?)
    locat.fix_succ!(nil)
  end

  def each
    @hd_locat.try { |x| yield x }

    @hd_pdmod.try { |x| yield x }
    @hd_nqmod.try { |x| yield x }
    @hd_dpmod.try { |x| yield x }

    yield noun

    @tl_dpmod.try { |x| yield x }
    @tl_nqmod.try { |x| yield x }
    @tl_pdmod.try { |x| yield x }
  end
end
