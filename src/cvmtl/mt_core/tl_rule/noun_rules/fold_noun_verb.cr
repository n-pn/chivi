module CV::TlRule
  def fold_noun_verb!(noun : MtNode, verb : MtNode)
    return noun if noun.prev?(&.preposes?)

    verb = fold_verbs!(verb)
    return noun unless verb.verb? && (succ = verb.succ?) && succ.ude1?
    return noun unless tail = scan_noun!(succ.succ?)

    defn = fold!(noun, succ.set!(""), PosTag::DefnPhrase, dic: 6)
    fold!(defn, tail, tail.tag, dic: 7, flip: true)
  end
end
