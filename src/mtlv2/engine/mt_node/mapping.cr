require "./mt_words/*"
require "./mt_forms/*"

module MtlV2::MTL
  # ameba:disable Metrics/CyclomaticComplexity
  def self.from_term(term : V2Term, tag = term.tags[0])
    case tag[0]?
    when 'N' then name_from_term(term, tag)
    when 'n' then noun_from_term(term, tag)
    when 'd' then advb_from_term(term, tag)
    when 'v' then verb_from_term(term, tag)
    when 'a' then adjt_from_term(term, tag)
    when 'c' then conj_from_term(term, tag)
    when 'u' then ptcl_from_term(term, tag)
    when 'm' then number_from_term(term, tag)
    when 'q' then quanti_from_term(term, tag)
    when 'r' then pronoun_from_term(term, tag)
    when 'p' then prepos_from_term(term, tag)
    when 'k' then suffix_from_term(term, tag)
    when 'x' then literal_from_term(term, tag)
    when '!' then special_from_term(term, tag)
    when 'w' then punct_from_term(term, tag)
    when '~' then extra_from_term(term, tag)
    else          BaseWord.new(term)
    end
  end

  def self.noun_from_term(term : V2Term, tag = term.tags[0])
    case tag[1]?
    when 'a' then TraitNoun.new(term)
    when 'p' then PlaceNoun.new(term)
    when 's' then PositNoun.new(term)
    when 'h' then HonorNoun.new(term)
    when 'b' then AbstrNoun.new(term)
    when 'f' then LocatWord.new(term)
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

  def self.advb_from_term(term : V2Term, tag = term.tags[0])
    case term.key
    when "不" then AdvbBu4.new(term)
    when "没" then AdvbMei.new(term)
    when "非" then AdvbFei.new(term)
    else          AdvbWord.new(term)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.ptcl_from_term(term : V2Term)
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
    when "一样", "一般", "似的", "般"  then PtctYy.new(term)
    when "来讲", "来说", "而言", "说来" then PtclLs.new(term)
    when "连"                    then PtclLian.new(term)
    else                             PtclWord.new(term)
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

  def self.suffix_from_term(term : V2Term)
    case term.tags[0][1]?
    when 'a' then SuffAdjt.new(term)
    when 'n' then SuffNoun.new(term)
    when 'v' then SuffVerb.new(term)
    else          SuffWord.new(term)
    end
  end

  def self.literal_from_term(term : V2Term, tag = term.tags[0])
    case tag[1]?
    when 'x' then Fixstr.new(term)
    when 'l' then Urlstr.new(term)
    else          Litstr.new(term)
    end
  end
end
