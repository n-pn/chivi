require "./mt_word/*"
require "./mt_form/*"

module MtlV2::MTL
  # ameba:disable Metrics/CyclomaticComplexity
  def self.from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[0]
    when 'N' then name_from_term(term, tag)
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

  def self.noun_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[1]?
    when 'a' then TraitNoun.new(term)
    when 'p' then PlaceNoun.new(term)
    when 's' then PositNoun.new(term)
    when 'h' then HonorNoun.new(term)
    when 'b' then AbstrNoun.new(term)
    when 'f' then LocatNoun.new(term)
    when 't' then TimeWord.new(term)
    else          NounWord.new(term)
    end
  end

  def self.name_from_term(term : V2Term, tag = term.tags[0])
    case tag[1]?
    when 'r' then HumanName.new(term)
    when 'a' then AffilName.new(term)
    when 'w' then TitleName.new(term)
    else          OtherName.new(term)
    end
  end

  # def self.affil_from_term(term : V2Term, tag = term.tags[0])
  #   case tags[2]?
  #   when 'l' then PlaceName.new(term)
  #   when 'g' then InstiName.new(term)
  #   else          AffilName.new(term)
  #   end
  # end

  def self.adjt_from_term(term : V2Term, tag = term.tags[0])
    case tag[1]?
    when 'n' then AjnoWord.new(term)
    when 'd' then AjadWord.new(term)
    else          AdjtWord.new(term)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.verb_from_term(term : V2Term)
    case term.tags[0][1]?
    # when nil then Verb.new(term)
    # when 'o' then VerbObject.new(term)
    # when 'n' then VerbNoun.new(term)
    # when 'd' then VerbAdvb.new(term)
    # when 'i' then IntrVerb.new(term)
    # when '2' then Verb2Obj.new(term)
    # when 'x' then VLinking.new(term)
    # when 'p' then VCompare.new(term)
    # when 'f' then VDircomp.new(term)
    when 'm' then vmodal_from_term(term)
    when '!' then uniq_verb_from_term(term)
    else          VerbWord.new(term)
    end
  end

  def self.advb_from_term(term : V2Term, tag = term.tags[0])
    case term.key
    when "不" then AdvbBu4.new(term)
    when "没" then AdvbMei.new(term)
    when "非" then AdvbFei.new(term)
    else          AdvbWord.new(term)
    end
  end

  def self.conj_from_term(term : V2Term, tag = term.tags[0])
    case tag[1]?
    when 'c' then ConjWord.new(term, :coordi)
    else          ConjWord.new(term, ConjType.from(term.key))
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.ptcl_from_term(term : V2Term, tag : String = "")
    case term.key
    when "了", "喽"               then PtclLe.new(term)
    when "之"                    then PtclZhi.new(term)
    when "着"                    then PtclZhe.new(term)
    when "过"                    then PtclGuo.new(term)
    when "的", "底"               then PtclDe1.new(term)
    when "地"                    then PtclDe2.new(term)
    when "得"                    then PtclDe3.new(term)
    when "所"                    then PtclSuo.new(term)
    when "的话"                   then PtclDehua.new(term)
    when "云云", "等", "等等"        then PtclDeng.new(term)
    when "一样", "一般", "似的", "般"  then PtclYy.new(term)
    when "来讲", "来说", "而言", "说来" then PtclLs.new(term)
    when "连"                    then PtclLian.new(term)
    else                             PtclWord.new(term)
    end
  end

  def self.pronoun_from_term(term : V2Term, tag = term.tags[0])
    case tag[1]?
    when 'z' then demspro_from_term(term, tag)
    when 'y' then intrpro_from_term(term, tag)
    when 'r' then perspro_from_term(term, tag)
    else          PronounWord.new(term)
    end
  end

  def self.demspro_from_term(term : V2Term, tag = term.tags[0])
    case term.key
    when "这" then ProZhe.new(term)
    when "那" then ProNa1.new(term)
    when "几" then ProJi3.new(term)
    else          DemsproWord.new(term)
    end
  end

  def self.intrpro_from_term(term : V2Term, tag = term.tags[0])
    case term.key
    when "哪" then ProNa2.new(term)
    else          IntrproWord.new(term)
    end
  end

  def self.perspro_from_term(term : V2Term, tag = term.tags[0])
    case term.key
    when "自己" then ProZiji.new(term)
    else           PersproWord.new(term)
    end
  end

  def self.number_from_term(term : V2Term)
    return NquantWord.new(term) if term.tags[0] == "mq"

    case
    when NdigitWord.matches?(term.key)
      NdigitWord.new(term)
    when NhanziWord.matches?(term.key)
      NhanziWord.new(term)
    else
      NumberWord.new(term)
    end
  end

  def self.quanti_from_term(term : V2Term)
    # TODO: add QuantiVerb, QuantiTime...
    QuantiWord.new(term)
  end

  def self.suffix_from_term(term : V2Term, tag : String = "")
    case tag[1]?
    when 'x' then SuffElse.new(term)
      # when '!' then # parse speical suffix here
    else SuffWord.new(term)
    end
  end

  def self.literal_from_term(term : V2Term, tag = term.tags[0])
    case tag[1]?
    when 'e' then Exclam.new(term)
    when 'y' then Mopart.new(term)
    when 'o' then Onomat.new(term)
    when 'l' then UrlLit.new(term)
    when 'x' then PreLit.new(term)
    else          RawLit.new(term)
    end
  end

  def self.prep_from_term(term : V2Term, tag : String)
    case term.key
    when "把" then PrepBa3.new(term)
    when "被" then PrepBei.new(term)
    when "对" then PrepDui.new(term)
    when "在" then PrepZai.new(term)
    when "比" then PrepBi3.new(term)
    else          PrepWord.new(term)
    end
  end

  def self.extra_from_term(term : V2Term, tag = term.tags[0])
    case tag
    when "~np" then NounPhrase.new(term)
    when "~vp" then VerbPhrase.new(term)
    when "~ap" then AdjtPhrase.new(term)
    when "~dp" then DefnPhrase.new(term)
    when "~pp" then PrepClause.new(term)
    when "~sv" then VerbClause.new(term)
    when "~sa" then AdjtClause.new(term)
    else            BaseWord.new(term)
    end
  end
end
