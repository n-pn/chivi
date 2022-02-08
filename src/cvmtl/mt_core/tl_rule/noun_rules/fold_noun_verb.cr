module CV::TlRule
  def fold_noun_verb!(noun : MtNode, verb : MtNode)
    return noun if noun.prev?(&.preposes?)

    verb = verb.vmodals? ? fold_vmodals!(verb) : fold_verbs!(verb)
    return noun unless (succ = verb.succ?) && succ.ude1? && (verb.verb? || verb.vmodals?)
    return noun unless tail = scan_noun!(succ.succ?)

    left = fold!(noun, verb, PosTag::VerbPhrase, dic: 4)
    defn = fold!(left, succ.set!("do"), PosTag::DefnPhrase, dic: 6, flip: true)
    tag = tail.names? || tail.human? ? tail.tag : PosTag::NounPhrase

    fold!(defn, tail, tag, dic: 5, flip: true)
  end
end
