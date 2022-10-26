module MT::TlRule
  def fold_verb_auxils!(verb : MtNode, auxil : MtNode) : MtNode
    case auxil.tag
    when .ptcl_le?
      fold_verb_ule!(verb, auxil)
      # return verb unless (succ = verb.succ?) && succ.numeral?

      # if is_pre_appro_num?(verb)
      #   succ = fuse_number!(succ) if succ.numeral?
      #   return fold!(verb, succ, succ.tag)
      # end

      # fold_verb_nquant!(verb, succ, has_ule: true)
    when .ptcl_dev?
      return verb unless (succ_2 = auxil.succ?) && (succ_2.verb_words? || succ_2.preposes?)
      node = fold!(verb, auxil.set!("mà"), MapTag::DrPhrase)

      succ_2 = fold_verbs!(succ_2)
      fold!(node, succ_2, succ_2.tag)
    when .ptcl_der?
      fold_verb_ude3!(verb, auxil)
    when .ptcl_guo?
      fold!(verb, auxil, verb.tag)
    else
      verb
    end
  end
end
