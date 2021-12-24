module CV::TlRule
  def fold_verb_nquant!(verb : MtNode, node : MtNode, has_ule = false)
    node = fuse_number!(node) if node.numbers?
    return verb unless node.nquants?

    if node.nqiffy? || node.nqnoun?
      return verb unless !has_ule || is_temp_nqverb?(node)
    end

    return fold!(verb, node, verb.tag, dic: 6)
  end

  def is_temp_nqverb?(node : MtNode)
    case node.key[-1]?
    when '把'
      node.val = node.val.sub("bả", "phát")
    when '脚', '眼', '圈', '次' # , '口'
      true
    else
      false
    end
  end
end
