require "./_rule_base"

module M2::MtRule
  # single-word nouns or names
  def_rule :NN do
    add_node(root, NP_Node.new(head), idx: idx)
  end

  copy_rule :NT, NN
  copy_rule :NR, NN

  # noun-noun compounds
  def_rule :NN, :NN do
    # TODO: check flip condition
    noun = MtPair.new(head, secd, flip: true)
    add_node(root, noun, idx: idx)
  end

  # time-time compounds
  def_rule :NT, :NT do
    # A sequence of NTs that form the dates are left flat and grouped as the
    # lowest level of NP

    noun = MtPair.new(head, secd, rank: 3, flip: true)
    add_node(root, noun, idx: idx)
  end

  # word-level coordinations
  def_rule :NN, :CC do
    tail_idx = idx &+ head.size &+ secd.size

    tail_map = root.all_nodes[tail_idx]
    return unless tail_nodes = tail_map[:NN]?

    tail_nodes.each_value do |tail_node|
      # TODO: check similarity
      # TODO: combine with ETC tag

      list = Slice[head, secd, tail_node]
      noun = MtExpr.new(list, :NN, rank: 3)
      add_node(root, noun, idx: idx)
    end
  end

  # proper nouns formed by NR + one or more NNs
  def_rule :NR, :NN do
    # TODO: check flip condition
    # - seperate between loc/org and person with titles
    # - space names + space (org/loc) suffix
    # - human names + title/honorific (suffix)

    if head.attr.human? && secd.attr.hsuff?
      ptag = :NR
      prop = head.attr
      rank = 5
      flip = false
    else
      ptag = :NP
      prop = secd.attr
      rank = 3
      flip = true
    end

    noun = MtPair.new(head, secd, ptag: ptag, prop: prop, rank: rank, flip: flip)
    add_node(root, noun, idx: idx)
  end

  def_rule :NR, :NR do
    # accept
    # - space names + space names
    # - space names + human names
    # - human names + human names
    # reject
    # - human names + space names

    if head.attr.human?
      return unless secd.attr.human?

      ptag = :NR
      prop = head.attr
      rank = 5
      flip = false
    else
      ptag = secd.ptag
      prop = secd.attr
      rank = 3
      flip = true
    end

    # A sequence of NRs that form the name of a place will also be
    # grouped as an NP, the internal structure of which is left flat:

    noun = MtPair.new(head, secd, ptag: ptag, prop: prop, rank: rank, flip: flip)
    add_node(root, noun, idx: idx)
  end

  # quantifier phrase + noun phrase
  def_rule :QP, :NP do
    # TODO: check matching quantifier and noun phrase
    # TODO: fix quantifier translation depend on noun type
    noun = NP_Node.new(head, secd, rank: 4)
    add_node(root, noun, idx: idx)
  end

  # determiner phrase + noun phrase
  def_rule :DP, :NP do
    # TODO: check matching quantifier and noun phrase
    # TODO: fix quantifier translation (if exists) depend on noun type

    # Note that not all determiners take QPs as complements.

    noun = NP_Node.new(head, secd, rank: 4)
    add_node(root, noun, idx: idx)
  end

  def_rule :ADJP, :NP do
    # ADJPs are projected by JJs and the noun head modified by ADJPs
    # always project to an NP.

    flip = !head.attr.xflip?
    noun = MtPair.new(head, secd, rank: 4, flip: flip)
    add_node(root, noun, idx: idx)
  end

  def_rule :NP, :ADJP do
    # When there are intervening ADJPs, the last NP is considered to be
    # the head and all the preceding NPs are considered to be modifiers.
    # Semantically such NP modifiers are often the possessor of the head noun:

    flip = !head.attr.xflip?
    tail_idx = idx &+ head.size &+ secd.size

    root.each_tail_node(tail_idx, :NP) do |tail|
      tert = MtPair.new(secd, tail, rank: 4, flip: flip)
      noun = MtPair.new(head, tert, rank: 3, flip: true)
      add_node(root, noun, idx: idx)
    end
  end

  def_rule :DNP, :NP do
    # DNPs are formed by various phrasal categories plus the (DEG 的). They always
    # occur in the context of NP. (DEG 的) has no content other than marking the
    # preceding phrase as an NP modifier.

    flip = !head.attr.xflip? # almost always flip, except for some special case
    noun = MtPair.new(head, secd, rank: 3, flip: flip)
    add_node(root, noun, idx: idx)
  end

  # Relative clauses with (DEC 的)
  #
  # 1. Headed relative clause with (DEC 的) and an NP trace:
  #
  # The gap can be in the topic position. Note also that the topic is at
  # the IP-level instead of the CP-level to ’vacate’ space for complementizers
  # and the relative operator
  #
  # There can be multiple relative clauses for a single NP head
  #
  # Relative clauses can be nested
  #
  # 2. Headed relative clause with and a PP-trace:
  # Headed relative clause with PP traces are not as easily detectable as relative
  # clauses with NP traces, since the underlying structure can possibly use a
  # variety of phrasal and clausal categories in the position of the PP trace. PP
  # trace is more appropriately understood as some kind of VP adjunct trace.
  # Still, we label the trace PP to differentiate this kind of relative clause
  # from relative clauses where the gap is an argument.
  #
  # Generally, the head of this type of relative clause denotes time, location,
  # reason, manner, etc. It differs from the relative clause with an NP trace
  # in that the gap is not an argument position. As such it typically occupies
  # a preverbal adjunct position in Chinese. If the VP has multiple adjuncts,
  # the gap is stipulated to be the first position after the subject.
  #
  # 3. Headless relatives:
  # There is no overt head in a relative construction although the NP as a whole
  # has an understood reference, either generic or implied in the context. The
  # gap is generally in an argument position.
  #
  # Note that the extra layer of NP outside the CP is used to mark its nominal
  # status.
  # The pseudo cleft construction in Chinese is structurally indistinct from the
  # headless relative construction so they are treated alike, although they may
  # very well be different pragmatically
  def_rule :IP, :DEC do
    # TODO: check for matching condition

    # return unless head.attr.ip_no_obj?
    # return unless head.attr.in?(:TIME, :SPACE, :REASON, :MANNER)

    nmod = MtPair.new(head, secd, rank: 2, flip: true)

    root.each_tail_node(idx &+ nmod.size, :NP) do |tail|
      noun = MtPair.new(nmod, tail, rank: 2, flip: true)
      add_node(root, noun, idx: idx)
    end
  end

  # Relative clauses without (DEC 的)
  def_rule :IP, :NP do
    # TODO
    # (a) with NP gap
    # (b) with PP gap
  end

  # Appositive constructions
  #
  # Appositive constructions are always NPs. Apposition can be viewed as a special
  # kind of modification. There are two scenarios where appositive constructions
  # can occur. The first one is when one NP modifies another NP and the two NPs
  # "mean or refer to the same entity". It differs from cases in which a noun
  # modifies a noun head. In the former case, the appositive is always a
  # phrasal category element, that is, an NP. In the latter case, the modifier
  # is a word level category element.
  #
  # Appositives of this type are attached at the same level as the NPs of
  # which they are appositives to and receive the functional tag -APP
  #
  # The second scenario where appositives happen is when a clause other than
  # a relative clause occurs inside an NP. No gap can be identified inside
  # the clause. Whether there is a gap or not is a definitive test for
  # distinguishing between a relative clause and an appositive clause; however,
  # sometimes this is not enough, especially when the gap is an adjunct.
  # In this case, the annotator should use the suggestive test that the
  # appositive clause "provides the content for the noun head". The noun head
  # and the appositive clause can be put in an equative frame like "noun head
  # 是 appositive clause".

  def_rule :IP, :NP do
    nmod = MtPair.new(head, secd, rank: 1, flip: false)

    root.each_tail_node(idx &+ nmod.size, :NR) do |tail|
      noun = MtPair.new(nmod, tail, rank: 2, flip: true)
      add_node(root, noun, idx: idx)
    end
  end
end
