module MT::Rules
  # check if objt can fold with left node
  # all assume that after objt is ptcl_dep

  def match_objt_prepos?(objt : MtNode, prepos : MtNode, tail : MtNode, after_is_pred = false)
    return false if objt.nattr? || objt.brand_name?

    case prepos
    when .prep_zai?
      return false if tail.spaceword? || tail.timeword?
      return true if objt.spaceword? || objt.timeword?
    end

    !after_is_pred
  end

  def match_objt_verbal?(objt : MtNode, verbal : MtNode, tail : MtNode, after_is_pred = false)
    return false if objt.spaceword?

    head = verbal.prev
    return true if after_is_pred && (verbal.vlinking? || verbal.modal_verbs? || head.unreal?)

    # puts [objt, verbal, prev]

    return true if head.v_shi?
    return false unless head.comma? && (head = head.prev?)

    # FIXME: check more case here
    head.subj_verb? || head.verb_no_obj?
  end

  def match_objt_quanti?(objt : MtNode, quanti : MtNode)
    # puts [objt, quanti, "match objt quanti"]
    return !(objt.nattr? || objt.nabst?) if quanti.numbers?

    qt_key = extract_quanti_key(quanti)
    return match_objt_quanti?(objt, qt_key) unless qt_key == '个'

    return true unless (succ = objt.succ) && succ.ptcl_dep?
    succ.succ? { |x| x.nattr? || x.nabst? }
  end

  def match_objt_quanti?(objt : MtNode, qt_key : Char)
    return match_name_quanti?(name: objt, qt_key: qt_key) if objt.name_words?

    case objt
    when .nabst?            then qt_key.in?('点', '.')
    when .nattr?            then false
    when .humankind?        then qt_key.in?('帮', '只')
    when .plant?            then qt_key.in?('丛', '.')
    when .animal?           then qt_key.in?('只', '.')
    when .weapon?, .inhand? then qt_key.in?('把', '.')
    when .nsolid?           then true
    else                         false
    end
  end

  def match_name_quanti?(name : MtNode, qt_key : Char)
    case name
    when .human_name? then qt_key.in?('只', '些')
    when .title_name? then qt_key.in?('本', '.')
    else                   false
    end
  end

  private def extract_quanti_key(quanti : MtNode)
    case quanti
    when MonoNode then quanti.key[-1]
    when PairNode, TrioNode, SeriNode
      extract_quanti_key(quanti.tail)
    else
      raise "invalid quantifier!"
    end
  end
end
