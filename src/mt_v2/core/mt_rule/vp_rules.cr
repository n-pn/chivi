require "./_rule_base"

module M2::MtRule
  # verb compounds

  # Coordinated verb compounds (VCD)

  # The verbs have the same subcategorization frames and share the arguments
  # in the context. If they are followed by objects, the annotation can be
  # seen as a short-hand of
  # (VP (VP V1 (NP-OBJ (-NONE- *RNR*-1))) (VP V2 (NP-OBJ ..)))
  def_rule :V_CD, :VV do
    return if secd.attr.no_vcd?

    verb = MtPair.new(head, secd, ptag: :VCD, rank: 4, flip: false)
    add_node(root, verb, idx: idx)
  end

  # Verb-resultative and verb-directional compounds (VRD):
  # In general, verb compounds of the category fall into two distinctive
  # constituents with the second constituent indicating the direction result
  # of the first constituent.
  def_rule :VV, :V_RD do
    return if secd.attr.no_vrd?
    prop = head.attr | MtAttr::NO_VRD

    verb = MtPair.new(head, secd, ptag: :VCD, prop: prop, rank: 4, flip: false)
    add_node(root, verb, idx: idx)
  end

  # Verb compounds forming a modifier + head relationship (VSB)
  # In this case the first constituent necessarily is intransitive and
  # there can be no adjuncts or aspect markers between them.
  def_rule :V_IN, :VV do
    verb = MtPair.new(head, secd, ptag: :VSB, rank: 3, flip: false)
    add_node(root, verb, idx: idx)
  end

  # Verb compounds formed by VV + VC (VCP):
  def_rule :VV, :VC do
    verb = MtPair.new(head, secd, ptag: :VCP, rank: 3, flip: false)
    add_node(root, verb, idx: idx)
  end
end
