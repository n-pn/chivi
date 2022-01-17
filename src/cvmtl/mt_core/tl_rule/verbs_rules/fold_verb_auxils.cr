module CV::TlRule
  def fold_verb_auxils!(verb : MtNode, auxil : MtNode) : MtNode
    case auxil.tag
    when .ule?
      verb = fold_verb_ule!(verb, auxil)
      return verb unless (succ = verb.succ?) && succ.numeric?

      if is_pre_appro_num?(verb)
        succ = fuse_number!(succ) if succ.numeric?
        return fold!(verb, succ, succ.tag, dic: 4)
      end

      return fold_verb_nquant!(verb, succ, has_ule: true)
    when .ude2?
      return verb unless (succ_2 = auxil.succ?) && (succ_2.verb? || succ_2.veno?)
      succ_2 = fold_verbs!(succ_2)
      auxil.set!("mà")
      fold!(verb, succ_2, PosTag::Verb, dic: 5)
    when .ude3?
      fold_verb_ude3!(verb, auxil)
    when .uguo?
      fold!(verb, auxil, PosTag::Verb, dic: 6)
    else
      verb
    end
  end
end
