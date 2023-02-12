module M1::TlRule
  # 0: fold all
  # 1: skip uzhi and space and let the caller handle it
  # 2: stop at concoords

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_nouns!(noun : MtNode, mode : Int32 = 0) : MtNode
    # return node if node.nform?

    while noun.nominal?
      break unless succ = noun.succ?
      succ = heal_mixed!(succ) if succ.polysemy?

      case succ
      when .middot?
        break unless (tail = succ.succ?) && succ.human?

        succ.val = ""
        noun = fold!(noun, tail, PosTag::Person, dic: 3)
      when .maybe_adjt?
        break if succ.adv_bu4?
        return fold_noun_adjt!(noun, succ)
      when .ude1?
        return noun if noun.prev?(&.verb?) && !noun.nattr?
        return fold_ude1!(ude1: succ, prev: noun)
      when .uzhi?
        # TODO: check with prev to group
        return mode == 0 ? fold_uzhi!(succ, noun) : noun
      when .uyy?
        adjt = fold!(noun, succ.set!("như"), PosTag::Aform, dic: 7, flip: true)
        return adjt unless (succ = adjt.succ?) && succ.maybe_adjt?
        succ = succ.adverbial? ? fold_adverbs!(succ) : fold_adjts!(succ)
        return fold!(adjt, succ, PosTag::Aform, dic: 8)
      when .spaces?
        return noun if noun.prev? { |x| x.numeral? || x.pronouns? || x.adjective? }
        noun = fold_noun_space!(noun, succ)
      when .verbal?
        return fold_noun_verb!(noun, succ)
      when .junction?
        break unless should_fold_noun_concoord?(noun, succ)
        fold_noun_concoord!(succ, noun).try { |fold| noun = fold } || break
      when .nominal?
        break if succ.ntime?
        return noun unless fold = fold_noun_noun!(noun, succ, mode: mode)
        noun = fold
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
