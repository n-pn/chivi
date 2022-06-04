module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_nouns!(noun : MtNode, defn : MtNode? = nil) : MtNode
    fold_mode = NounMode.init(noun, prev: defn ? defn.prev? : noun.prev?)

    while succ = noun.succ?
      case succ
      when .middot?
        return noun unless tail = succ.succ?
        succ.val = ""
        noun = fold!(noun, tail, PosTag::Person, dic: 3)
      when .locality?
        unless succ.succ? { |x| x.nominal? || x.key == "第" }
          break if fold_mode.no_locality?
        end

        noun = fold_defn_noun!(noun: noun, defn: defn) if defn
        defn = nil

        noun = fold_noun_locality!(noun, succ)
        break if noun.succ? == succ
      when .mixed?
        succ = heal_mixed!(succ)
        break if succ.mixed?
      when .nominal?
        unless noun.nattr? || fold_mode.fold_all?
          break if noun_is_subject?(succ)
        end

        noun = fold_noun_noun!(noun, succ, mode: fold_mode)
      when .special?
        break unless succ.key == "第"

        succ = fold_第!(succ)
        ptag = succ.tag.numeral? ? noun.tag : succ.tag
        noun = fold!(noun, succ, ptag, dic: 6, flip: true)
      else
        break
      end

      # if succ == noun.succ?
      #   puts [noun, succ]
      #   exit 1
      # end
    end

    noun = fold_defn_noun!(noun: noun, defn: defn) if defn
    return noun unless succ = noun.succ?

    # puts [noun, succ, fold_mode, "fold_noun"]

    if succ.ude1?
      return noun unless right = fold_right_of_ude1(fold_mode, succ.succ?)
      noun = fold_ude1!(ude1: succ, left: noun, right: right)
      return noun unless succ = noun.succ?
    end

    fold_noun_other!(noun, succ)
  end

  def fold_right_of_ude1(mode : NounMode, right : MtNode?) : MtNode?
    return if !right || right.ends?

    right = fold_once!(right)
    # puts [mode, right]
    return right if right.object? && !mode.no_ude1?
  end

  @[AlwaysInline]
  def fold_defn_noun!(noun : MtNode, defn : MtNode) : MtNode
    flip = !defn.modi? || !defn.key.in?("原", "所有", "所有的")
    fold!(defn, noun, noun.tag, dic: 6, flip: flip)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_other!(noun : MtNode, succ = noun.succ) : MtNode
    succ = fold_once!(succ)

    case succ
    when .adjective?
      return noun if succ.adv_bu4?
      noun = fold_noun_adjt!(noun, succ)
    when .uzhi?
      noun.prev?(&.verb?) ? noun : fold_uzhi!(succ, noun)
    when .uyy?
      adjt = fold!(noun, succ.set!("như"), PosTag::Aform, dic: 7, flip: true)

      unless (succ = adjt.succ?) && succ.maybe_adjt?
        return fold_adjts!(adjt)
      end

      succ = succ.adverbial? ? fold_adverbs!(succ) : fold_adjts!(succ)
      noun = fold!(adjt, succ, PosTag::AdjtPhrase, dic: 8)
    when .verbal?
      noun = fold_noun_verb!(noun, succ)
    when .junction?
      return noun unless should_fold_noun_concoord?(noun, succ)
      fold_noun_concoord!(succ, noun) || noun
    when .usuo?
      succ.succ?(&.verbal?) ? noun : fold_suffix!(noun, succ)
    when .suffixes? then fold_suffix!(noun, succ)
    else
      noun
    end
  end
end
