module CV::TlRule
  # 0: fold all
  # 1: skip uzhi and space and let the caller handle it
  # 2: stop at concoords

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_nouns!(noun : MtNode, mode : Int32 = 0) : MtNode
    # return node if node.nform?

    while noun.nouns?
      break unless succ = noun.succ?

      case succ
      when .maybe_adjt?
        break if succ.adv_bu?
        return fold_noun_adjt!(noun, succ)
      when .middot?
        break unless (succ_2 = succ.succ?) && succ_2.human?
        succ.val = ""
        noun = fold!(noun, succ_2, PosTag::Person, dic: 3)
      when .ude1?
        noun = fold_ude1!(ude1: succ, prev: noun) if noun.nattr?
        return noun
      when .uzhi?
        # TODO: check with prev to group
        return mode == 0 ? fold_uzhi!(succ, noun) : noun
      when .uyy?
        adjt = fold!(noun, succ.set!("như"), PosTag::Aform, dic: 7, flip: true)
        return adjt unless (succ = adjt.succ?) && succ.maybe_adjt?
        succ = succ.adverbs? ? fold_adverbs!(succ) : fold_adjts!(succ)
        return fold!(adjt, succ, PosTag::Aform, dic: 8)
      when .spaces?
        return noun if noun.prev? { |x| x.numeric? || x.pronouns? }
        noun = fold_noun_space!(noun, succ)
      when .verbs?
        return fold_noun_verb!(noun, succ)
      when .veno?
        succ = heal_veno!(succ)
        return fold_noun_verb!(noun, succ) if succ.verbs?
        noun = fold!(noun, succ, PosTag::Noun, dic: 7, flip: true)
      when .junction?
        break unless should_fold_noun_concoord?(noun, succ)
        fold_noun_concoord!(succ, noun).try { |fold| noun = fold } || break
      when .time?
        break
      when .nouns?
        return noun unless fold = fold_noun_noun!(noun, succ, mode: mode)
        noun = fold
      when .suf_verb?
        return fold_suf_verb!(noun, succ)
      when .suf_noun?
        noun = fold_suf_noun!(noun, succ)
      when .usuo?
        break if succ.succ?(&.verbs?)
        noun = fold_suf_noun!(noun, succ)
      when .specials?
        case succ.key
        when "第"
          succ = fold_第!(succ)
          noun = fold!(noun, succ, succ.tag, dic: 6, flip: true) unless succ.nquants?
        end

        break
      else
        break
      end

      break if succ == noun.succ?
    end

    noun
  end
end
