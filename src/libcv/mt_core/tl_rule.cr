require "./tl_rule/*"

module CV::TlRule
  def fix_grammar!(node : MtNode, mode = 1) : Nil
    while node = node.succ?
      # puts [node, node.succ?, node.body?]
      # gets

      case node.tag
      when .puncts?
        case node.tag
        when .quoteop? then node = fold_quotes!(node, mode: mode)
        else
          # TODO
          node
        end
      when .auxils?   then node = heal_auxils!(node, mode: mode)
      when .strings?  then node = fold_strings!(node)
      when .preposes? then node = fold_preposes!(node)
      when .pronouns? then node = fold_pronouns!(node)
      when .numbers? # , .quantis?
        node = fold_number!(node)
        node = fold_noun_left!(node) if node.nquants? && !node.succ?(&.nouns?)
        # when .vshi? then next # TODO handle vshi
        # when .vyou? then next # TODO handle vyou
      when .veno?
        node = heal_veno!(node)
        node = node.noun? ? fold_noun!(node) : fold_verbs!(node)
      when .adverbs?
        node = fold_adverbs!(node)
      when .adjts?
        node = fold_adjts!(node, prev: nil)
        next unless node.nouns?
        node = fold_noun_left!(node, mode: mode)
      when .space?
        if node.prev.nouns?
          node = fold_noun_space!(node.prev, node)
        else
          node = fold_noun_left!(node, mode: mode)
        end
      when .vshang?, .vxia?
        if node.prev.nouns?
          node = fold_noun_space!(node.prev, node)
        else
          node = fold_verbs!(node)
        end
      when .vmodals? then node = heal_vmodal!(node)
      when .verbs?   then node = fold_verbs!(node)
      when .nform?
        node = fold_noun_left!(node, mode: mode)
      when .nouns?
        node = fold_noun!(node)
        next unless node.nouns?
        node = fold_noun_left!(node, mode: mode)
      when .special?
        node = fix_by_key!(node)
      end
    end
  end

  private def fix_by_key!(node : MtNode, succ = node.succ?) : MtNode
    case node.key
    when "完"
      node.val = "nộp"
      node.tag = PosTag::Verb
      return fold_verbs!(node)
    when "对不起"
      boundary?(succ) ? node : fold_verbs!(node.heal!("có lỗi với", PosTag::Verb))
    when "百分之"
      return node unless succ && succ.numbers?
      succ = fold_number!(succ)
      node.fold!(succ, "#{succ.val} #{node.val}")
    when "原来"
      if succ.try(&.ude1?) || node.prev?(&.contws?)
        node.heal!("ban đầu", tag: PosTag::Modifier)
      else
        node.heal!("thì ra")
      end
    when "行"
      boundary?(succ) ? node.heal!("được") : node
    when "高达"
      if succ.try(&.nquants?)
        node.heal!("cao đến")
      else
        node.heal!(tag: PosTag::Noun)
      end
    else
      node
    end
  end

  private def fix_quoteop!(node : MtNode)
    return node unless succ = node.succ?
    return node unless succ_2 = succ.succ?
    return node unless succ_2.quotecl?

    node.dic = 6
    node.tag = succ.tag
    note.val = "#{node.val}#{succ.val}#{succ_2.val}"
    node.fold_many!(succ, succ_2)
  end
end
