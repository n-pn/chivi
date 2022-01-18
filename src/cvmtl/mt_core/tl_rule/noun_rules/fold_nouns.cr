module CV::TlRule
  # 0: fold all
  # 1: skip uzhi and space and let the caller handle it
  # 2: stop at concoords

  def fold_nouns!(noun : MtNode, mode : Int32 = 0) : MtNode
    # return node if node.nform?

    while noun.nouns?
      break unless succ = noun.succ?

      case succ
      when .maybe_adjt?
        return fold_noun_adjt!(noun, succ)
      when .middot?
        break unless (succ_2 = succ.succ?) && succ_2.human?
        succ.val = ""
        noun = fold!(noun, succ_2, PosTag::Person, dic: 3)
      when .uzhi?
        # TODO: check with prev to group
        return mode == 0 ? fold_uzhi!(succ, noun) : noun
      when .veno?
        succ = heal_veno!(succ)
        return noun if succ.verbs?
        noun = fold!(noun, succ, PosTag::Noun, dic: 7, flip: true)
      when .junction?
        return noun if mode == 2 || noun.prev?(&.adjts?)
        fold_noun_concoord!(succ, noun).try { |fold| noun = fold } || break
      when .spaces?
        return mode == 0 ? fold_noun_space!(noun, succ) : noun
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
      when .uniques?
        case succ.key
        when "第"
          noun = fold!(noun, fold_第!(succ), succ.tag, dic: 6, flip: true)
        else
          # TODO!
          break
        end
      else
        break
      end

      break if succ == noun.succ?
    end

    noun
  end
end
