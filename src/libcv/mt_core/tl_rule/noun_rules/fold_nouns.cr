module CV::TlRule
  # 0: fold all
  # 1: skip uzhi and space and let the caller handle it
  # 2: stop at concoords

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_nouns!(noun : MtNode, mode : Int32 = 0) : MtNode
    # return node if node.nform?

    if (succ = noun.succ?) && (succ.nominal? || succ.middot?)
      noun = fuse_noun!(noun, succ)
    end

    case succ = noun.succ?
    when .maybe_adjt?
      return fold_noun_adjt!(noun, succ) unless succ.adv_bu4?
    when .ude1?
      noun = fold_ude1!(ude1: succ, prev: noun) if noun.nattr?
      return noun
    when .uzhi?
      # TODO: check with prev to group
      return mode == 0 ? fold_uzhi!(succ, noun) : noun
    when .uyy?
      adjt = fold!(noun, succ.set!("như"), PosTag::Aform, dic: 7, flip: true)
      return adjt unless (succ = adjt.succ?) && succ.maybe_adjt?
      succ = succ.adverbial? ? fold_adverbs!(succ) : fold_adjts!(succ)
      return fold!(adjt, succ, PosTag::Aform, dic: 8)
    when .verbal?
      return fold_noun_verb!(noun, succ)
    when .veno?
      succ = heal_veno!(succ)
      return fold_noun_verb!(noun, succ) if succ.verbal?
      noun = fold!(noun, succ, PosTag::Noun, dic: 7, flip: true)
    when .junction?
      break unless should_fold_noun_concoord?(noun, succ)
      fold_noun_concoord!(succ, noun).try { |fold| noun = fold } || break
    when .suffixes?
      unless succ.key == "时" && noun.prev?(&.verb?)
        noun = fold_suffixes!(noun, succ)
      end
    when .usuo?
      break if succ.succ?(&.verbal?)
      noun = fold_suf_noun!(noun, succ)
    when .specials?
      case succ.key
      when "第"
        succ = fold_第!(succ)
        noun = fold!(noun, succ, succ.tag, dic: 6, flip: true) unless succ.nquants?
      end
    end

    noun
  end

  def fuse_noun!(noun : MtNode, succ = noun.succ) : MtNode
    case succ
    when .middot?
      return noun unless (succ_2 = succ.succ?) && succ_2.human?
      succ.val = ""
      noun = fold!(noun, succ_2, PosTag::Person, dic: 3)
    when .spaces?
      return noun if noun.prev? { |x| x.numeral? || x.pronouns? || x.adjective? }
      noun = fold_noun_space!(noun, succ)
    else
      noun
    end
  end

  def fuse_noun!(noun : MtNode, succ = nil) : MtNode
    noun
  end
end
