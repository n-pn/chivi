module M1::TlRule
  def fold_verb_auxils!(verb : MtNode, auxil : MtNode) : MtNode
    case auxil.tag
    when .ule?
      verb = fold_verb_ule!(verb, auxil)
      return verb unless (succ = verb.succ?) && succ.numeral?

      if is_pre_appro_num?(verb)
        succ = fuse_number!(succ) if succ.numeral?
        return fold!(verb, succ, succ.tag, dic: 4)
      end

      fold_verb_nquant!(verb, succ, has_ule: true)
    when .ude2?
      return verb unless (succ_2 = auxil.succ?) && (succ_2.verbal? || succ_2.preposes?)
      node = fold!(verb, auxil.set!("mà"), PosTag::Adverb, dic: 6)

      succ_2 = fold_verbs!(succ_2)
      fold!(node, succ_2, succ_2.tag, dic: 5)
    when .ude3?
      fold_verb_ude3!(verb, auxil)
    when .uguo?
      fold!(verb, auxil, PosTag::Verb, dic: 6)
    else
      verb
    end
  end
end
