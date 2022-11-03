module MT::Rules
  # check if noun can fold with left node
  # all assume that after noun is ptcl_dep

  def match_noun_quanti?(noun : MtNode, quanti : MtNode)
    # puts [noun, quanti, "match noun quanti"]
    return !(noun.nattr? || noun.nabst?) if quanti.numbers?

    qt_key = extract_quanti_key(quanti)
    return match_noun_quanti?(noun, qt_key) unless qt_key == '个'

    return true unless (succ = noun.succ) && succ.ptcl_dep?
    succ.succ? { |x| x.nattr? || x.nabst? }
  end

  def match_noun_quanti?(noun : MtNode, qt_key : Char)
    return match_name_quanti?(name: noun, qt_key: qt_key) if noun.name_words?

    case noun
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
