require "./mt_word/*"
require "./mt_form/*"

module MtlV2::MTL
  # ameba:disable Metrics/CyclomaticComplexity
  def self.from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[0]
    when 'N' then NounWord.new(term, pos)
    when 'n' then noun_from_term(term, pos)
    when 'd' then advb_from_term(term, pos)
      # when 'v' then verb_from_term(term, pos)
    when 'a' then adjt_from_term(term, pos)
    when 'c' then conj_from_term(term, pos)
    when 'u' then ptcl_from_term(term, pos)
      # when 'm' then number_from_term(term, pos)
      # when 'q' then quanti_from_term(term, pos)
    when 'r' then pronoun_from_term(term, pos)
    when 'p' then prep_from_term(term, pos)
    when 'k' then suffix_from_term(term, pos)
    when 'x' then literal_from_term(term, pos)
      # when '!' then uniq_from_term(term, pos)
    when '~' then extra_from_term(term, pos)
    when 'w' then PunctWord.new(term, pos)
    when 'i' then IdiomWord.new(term, pos)
    else          BaseWord.new(term, pos)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.verb_from_term(term : V2Term)
    case term.tags[0][1]?
    # when nil then Verb.new(term, pos: pos)
    # when 'o' then VerbObject.new(term, pos: pos)
    # when 'n' then VerbNoun.new(term, pos: pos)
    # when 'd' then VerbAdvb.new(term, pos: pos)
    # when 'i' then IntrVerb.new(term, pos: pos)
    # when '2' then Verb2Obj.new(term, pos: pos)
    # when 'x' then VLinking.new(term, pos: pos)
    # when 'p' then VCompare.new(term, pos: pos)
    # when 'f' then VDircomp.new(term, pos: pos)
    when 'm' then vmodal_from_term(term)
    when '!' then uniq_verb_from_term(term)
    else          VerbWord.new(term, pos: pos)
    end
  end

  def self.conj_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""
    case tag[1]?
    when 'c' then ConjWord.new(term, :coordi)
    else          ConjWord.new(term, ConjType.from(term.key))
    end
  end

  def self.suffix_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[1]?
    when 'x' then SuffElse.new(term, pos: pos)
      # when '!' then # parse speical suffix here
    else SuffWord.new(term, pos: pos)
    end
  end

  def self.literal_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[1]?
    when 'e' then Exclam.new(term, pos: pos)
    when 'y' then Mopart.new(term, pos: pos)
    when 'o' then Onomat.new(term, pos: pos)
    when 'l' then UrlLit.new(term, pos: pos)
    when 'x' then PreLit.new(term, pos: pos)
    else          RawLit.new(term, pos: pos)
    end
  end

  def self.prep_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "把" then PrepBa3.new(term, pos: pos)
    when "被" then PrepBei.new(term, pos: pos)
    when "对" then PrepDui.new(term, pos: pos)
    when "在" then PrepZai.new(term, pos: pos)
    when "比" then PrepBi3.new(term, pos: pos)
    else          PrepWord.new(term, pos: pos)
    end
  end

  def self.extra_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag
    when "~np" then NounPhrase.new(term, pos: pos)
    when "~vp" then VerbPhrase.new(term, pos: pos)
    when "~ap" then AdjtPhrase.new(term, pos: pos)
    when "~dp" then DefnPhrase.new(term, pos: pos)
    when "~pp" then PrepClause.new(term, pos: pos)
    when "~sv" then VerbClause.new(term, pos: pos)
    when "~sa" then AdjtClause.new(term, pos: pos)
    else            BaseWord.new(term, pos: pos)
    end
  end
end
