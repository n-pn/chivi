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
      when .usuo?
        break if succ.succ? { |x| x.verbal? && !x.v_shi? && !x.v_you? }
        noun = fold!(noun, succ.set!("nơi"), PosTag::Naffil, flip: true)
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

    # puts [noun, succ, noun.prev?, fold_mode, "fold_noun"]

    if succ.ude1?
      return noun if (noun.position? || noun.locative?) && noun.prev?(&.pro_per?)
      return noun unless right = fold_right_of_ude1(fold_mode, succ.succ?)
      noun = fold_ude1!(ude1: succ, left: noun, right: right)
      return noun unless succ = noun.succ?
    end

    # puts [noun, succ, fold_mode, "fold_noun"]

    fold_noun_other!(noun, succ, fold_mode)
  end

  def fold_right_of_ude1(mode : NounMode, right : MtNode?) : MtNode?
    return if !right || right.ends?

    right = fold_once!(right)
    # puts [mode, right]
    return right if right.object? && !mode.no_ude1?

    return unless tail = right.succ?
    return right if tail.suffixes?
  end

  @[AlwaysInline]
  def fold_defn_noun!(noun : MtNode, defn : MtNode) : MtNode
    flip = !defn.modi? || !defn.key.in?("原", "所有", "所有的")
    fold!(defn, noun, noun.tag, dic: 6, flip: flip)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_other!(noun : MtNode, succ = noun.succ?, mode : NounMode? = nil) : MtNode
    return noun if !succ || succ.ends?
    return fold_suffix!(noun, succ) if succ.suffixes?

    if succ.pro_per?
      return noun unless succ.key == "自己"
      noun = fold!(noun, succ, noun.tag, dic: 6, flip: true)
      return noun unless succ = noun.succ?
    end

    if succ.uzhi?
      noun = fold_uzhi!(uzhi: succ, prev: noun)
      return noun unless succ = noun.succ?
    end

    if succ.locality?
      return noun if noun.prev? { |x| x.nquants? || x.pro_dem? }
      noun = fold_noun_locality!(noun: noun, locality: succ)
      return noun unless succ = noun.succ?
    end

    if succ.junction?
      return noun unless fold = fold_noun_junction!(succ, prev: noun)
      noun = fold
      return noun unless succ = noun.succ?
    end

    # puts [noun, succ, mode, "fold_noun"]

    if succ.ude1?
      mode ||= NounMode.init(noun, noun.prev?)
      return noun unless right = fold_right_of_ude1(mode, succ.succ?)
      noun = fold_ude1!(ude1: succ, left: noun, right: right)
      return noun unless succ = noun.succ?
    end

    succ = fold_once!(succ)

    case succ
    when .adjective?
      return noun if succ.adv_bu4?
      fold_noun_adjt!(noun, succ)
    when .uyy?
      adjt = fold!(noun, succ.set!("như"), PosTag::Aform, dic: 7, flip: true)
      fold_adjts!(adjt)
    when .verbal?
      fold_noun_verb!(noun, succ)
    else
      noun
    end
  end
end
