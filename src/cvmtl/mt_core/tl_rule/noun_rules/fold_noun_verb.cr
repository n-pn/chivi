module CV::TlRule
  def fold_noun_verb!(noun : MtNode, verb : MtNode)
    return noun if noun.prev?(&.preposes?)

    verb = verb.vmodals? ? fold_vmodals!(verb) : fold_verbs!(verb)
    return noun unless (succ = verb.succ?) && succ.ude1? && (verb.verb? || verb.vmodals?)
    return noun unless tail = scan_noun!(succ.succ?)

    defn = fold!(noun, succ.set!(""), PosTag::DefnPhrase, dic: 6)
    tag = tail.names? || tail.human? ? tail.tag : PosTag::NounPhrase

    fold!(defn, tail, tag, dic: 5, flip: true)
  end
end
