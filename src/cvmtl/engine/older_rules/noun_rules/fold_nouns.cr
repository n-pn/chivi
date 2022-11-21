module MT::TlRule
  # 0: fold all
  # 1: skip uzhi and space and let the caller handle it
  # 2: stop at concoords

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_nouns!(noun : MtNode, mode : Int32 = 0) : MtNode
    # return node if node.nform?

    while noun.all_nouns?
      break unless succ = noun.succ?
      succ = heal_mixed!(succ) if succ.polysemy?

      case succ
      when .middot?
        break unless (tail = succ.succ?) && succ.cap_human?
        succ.val = ""
        noun = fold!(noun, tail, tail.tag)
      when .maybe_adjt?
        break if succ.adv_bu4?
        return fold_noun_adjt!(noun, succ)
      when .ptcl_dep?
        return noun if noun.prev?(&.verb?) && !noun.nattr?
        return fold_ude1!(ude1: succ, prev: noun)
      when .ptcl_zhi?
        # TODO: check with prev to group
        return mode == 0 ? fold_uzhi!(succ, noun) : noun
      when .ptcl_cmps?
        adjt = fold!(noun, succ.set!("như"), PosTag.make(:amix), flip: true)
        return adjt unless (succ = adjt.succ?) && succ.maybe_adjt?
        succ = succ.advb_words? ? fold_adverbs!(succ) : fold_adjts!(succ)
        return fold!(adjt, succ, PosTag.make(:amix))
      when .position?
        return noun if noun.prev? { |x| x.numeral? || x.all_prons? || x.adjt_words? }
        noun = fold_noun_space!(noun, succ)
      when .verbal_words?
        return fold_noun_verb!(noun, succ)
      when .bond_word?
        break unless should_fold_noun_concoord?(noun, succ)
        fold_noun_concoord!(succ, noun).try { |fold| noun = fold } || break
      else
        break
      end

      break if succ == noun.succ?
    end

    noun
  end
end
