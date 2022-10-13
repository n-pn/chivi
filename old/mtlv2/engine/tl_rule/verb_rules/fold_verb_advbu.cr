module MT::TlRule
  def fold_verb_advbu!(verb : MtNode, adv_bu : MtNode, tail = adv_bu.succ?) : MtNode
    return verb.flag!(:resolved) unless tail

    unless tail.key == verb.key
      verb = fold!(verb, adv_bu, verb.tag, dic: 4)
      return fuse_verb_compl!(verb, tail)
    end

    verb.val = "hay"
    verb = fold!(verb, adv_bu, tag: adv_bu.tag, dic: 2)
    verb2 = fuse_verb!(tail)

    fold!(verb, verb2, tag: verb2.tag, dic: 5, flip: true)
  end
end
