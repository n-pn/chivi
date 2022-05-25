# compare using 比
# reference: https://tiengtrungthuonghai.vn/cau-so-sanh-dung-chu%E6%AF%94/

# patterns
# - A 比 B + adjective
# - A 比 B + adjective + 一点/一些/多/多了/得多/nquants
# - A 比 B + verb + object
# - A 比 B + verb + 得 + adjective
# - A + verb + 得 + 比 B + adjective
# - A 比 B + verb + object + verb + 得 + adjective
# - A + verb + object + verb + 得 + 比 B + adjective
# - A 比 B + 早/晚/多/少 + verb + …

module CV::TlRule
  def fold_compare_bi3!(prepos : MtNode, succ = prepos.succ?, mode = 0)
    return prepos unless (noun = scan_noun!(succ, mode: mode)) && noun.object?

    unless succ = noun.succ?
      prepos = fold!(prepos, noun, PosTag::PrepClause, dic: 3)
      return prepos.flag!(:resolved)
    end

    succ = fold_once!(succ)
    # puts [succ, succ.tag, succ.verbal?]

    if succ.verbal?
      # succ = fold_verb_object!(succ, succ.succ?) unless succ.v0_obj?
      noun = fold!(noun, succ, PosTag::VerbClause, dic: 6) unless succ.v0_obj?
    end

    if (tail = noun.succ?) && tail.ude1? && tail.succ?(&.maybe_adjt?)
      if noun.verb_clause?
        flip = false
        tail.set!("")
      else
        flip = true
        tail.set!("của")
      end

      noun = fold!(noun, tail, PosTag::DefnPhrase, dic: 7, flip: flip)
    end

    return prepos unless tail = scan_adjt!(noun.succ?)
    return prepos unless tail.adjective? || tail.verb_object?

    output = MtNode.new("", "", PosTag::Unkn, dic: 1, idx: prepos.idx)
    output.fix_prev!(prepos.prev?)
    output.fix_succ!(tail.succ?)

    noun.fix_succ!(nil)

    if prepos.key == "不比"
      adv_bu = MtNode.new("不", "không", PosTag::AdvBu4, 1, prepos.idx)
      output.set_body!(adv_bu)
      adv_bu.fix_succ!(tail)

      prepos = MtNode.new("比", "bằng", PosTag::PreBi3, 1, prepos.idx + 1)
      tail.fix_succ!(prepos)
      prepos.fix_succ!(noun)
    else
      output.set_body!(tail)
      tail.fix_prev!(nil)
      tail.fix_succ!(prepos.set!("hơn"))
    end

    fold_compare_bi3_after!(output, noun)
  end

  def fold_compare_bi3_after!(node : MtNode, last : MtNode)
    return node unless (succ = node.succ?) && succ.auxils? && (tail = succ.succ?)

    case succ
    when .ule?
      return node unless tail.key == "点"
      last.fix_succ!(succ.set!(""))
      node.fix_succ!(tail.succ?)
      tail.fix_succ!(nil)
      node.set!(PosTag::Aform)
    when .ude1?, .ude3?
      return node unless tail.key == "多"
      last.fix_succ!(succ.set!(""))
      node.fix_succ!(tail.succ?)
      tail.fix_succ!(nil)
      node
    else
      node
    end
  end
end
