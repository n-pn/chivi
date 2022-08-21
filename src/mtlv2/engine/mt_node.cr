require "./mt_node/*"

module MtlV2::MTL
  # ameba:disable Metrics/CyclomaticComplexity
  def self.from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[0]?
    when 'N' then NounWord.new(term, pos)
    when 'n' then noun_from_term(term, pos)
    when 'd' then AdvbWord.new(term, pos: pos)
    when 'v' then verb_from_term(term, pos)
    when 'a' then adjt_from_term(term, pos)
    when 'c' then conj_from_term(term, pos)
    when 'u' then ptcl_from_term(term, pos)
    when 'm' then number_from_term(term, pos)
    when 'q' then quanti_from_term(term, pos)
    when 'r' then pronoun_from_term(term, pos)
    when 'p' then prepos_from_term(term, pos)
    when 'k' then suffix_from_term(term, pos)
    when 'x' then literal_from_term(term, pos)
    when '!' then unique_from_term(term, pos)
    when '~' then phrase_from_term(term, pos)
    when 'w' then PunctWord.new(term, pos)
    when 'i' then IdiomWord.new(term, pos)
    else          BaseWord.new(term, pos)
    end
  end

  def self.noun_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""
    case tag[1]?
    when 'h' then HonorNoun.new(term, pos)
    when 'f' then LocatNoun.new(term, pos)
    when 't' then TimeWord.new(term, pos)
    else          NounWord.new(term, pos)
    end
  end

  def self.adjt_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""
    case tag[1]?
    when 'n' then AjnoWord.new(term, pos: pos)
    when 'd' then AjadWord.new(term, pos: pos)
    else          AdjtWord.new(term, pos: pos)
    end
  end

  def self.verb_from_term(term : V2Term, pos = 0)
    tag = term.tags[pos]? || "v"
    return VerbWord.new(term, pos: pos) unless tag[1]? == '!'

    case key = term.key
    when "会"                 then VmHui.new(term, pos)
    when "能"                 then VmNeng.new(term, pos)
    when "想"                 then VmXiang.new(term, pos)
    when key.ends_with?('是') then VShiWord.new(term, pos)
    when key.ends_with?('有') then VYouWord.new(term, pos)
    else                          VerbWord.new(term, pos)
    end
  end

  def self.number_from_term(term : V2Term, pos : Int32 = 0)
    return NquantWord.new(term, pos: pos) if term.tags[0] == "mq"

    case
    when NdigitWord.matches?(term.key) then NdigitWord.new(term, pos: pos)
    when NhanziWord.matches?(term.key) then NhanziWord.new(term, pos: pos)
    else                                    NumberWord.new(term, pos: pos)
    end
  end

  def self.quanti_from_term(term : V2Term, pos : Int32 = 0)
    # TODO: add QuantiVerb, QuantiTime...
    QuantiWord.new(term, pos: pos)
  end

  ####

  def self.pronoun_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[1]?
    when 'z' then demspro_from_term(term, pos: pos)
    when 'y' then intrpro_from_term(term, pos: pos)
    when 'r' then perspro_from_term(term, pos: pos)
    else          PronounWord.new(term, pos: pos)
    end
  end

  def self.demspro_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "这" then ProZhe.new(term, pos: pos)
    when "那" then ProNa1.new(term, pos: pos)
    when "几" then ProJi3.new(term, pos: pos)
    else          DemsproWord.new(term, pos: pos)
    end
  end

  def self.intrpro_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "哪" then ProNa2.new(term, pos: pos)
    else          IntrproWord.new(term, pos: pos)
    end
  end

  def self.perspro_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "自己" then ProZiji.new(term, pos: pos)
    else           PersproWord.new(term, pos: pos)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.ptcl_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "了", "喽"               then PtclLe.new(term, pos: pos)
    when "之"                    then PtclZhi.new(term, pos: pos)
    when "着"                    then PtclZhe.new(term, pos: pos)
    when "过"                    then PtclGuo.new(term, pos: pos)
    when "的", "底"               then PtclDe1.new(term, pos: pos)
    when "地"                    then PtclDe2.new(term, pos: pos)
    when "得"                    then PtclDe3.new(term, pos: pos)
    when "所"                    then PtclSuo.new(term, pos: pos)
    when "的话"                   then PtclDehua.new(term, pos: pos)
    when "云云", "等", "等等"        then PtclDeng.new(term, pos: pos)
    when "一样", "一般", "似的", "般"  then PtclYy.new(term, pos: pos)
    when "来讲", "来说", "而言", "说来" then PtclLs.new(term, pos: pos)
    when "连"                    then PtclLian.new(term, pos: pos)
    else                             PtclWord.new(term, pos: pos)
    end
  end

  ####
  def self.prepos_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "把" then PrepBa3.new(term, pos: pos)
    when "被" then PrepBei.new(term, pos: pos)
    when "对" then PrepDui.new(term, pos: pos)
    when "在" then PrepZai.new(term, pos: pos)
    when "比" then PrepBi3.new(term, pos: pos)
    else          PrepWord.new(term, pos: pos)
    end
  end

  def self.conj_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""
    case tag[1]?
    when 'c' then ConjWord.new(term, :coordi)
    else          ConjWord.new(term, ConjType.from(term.key))
    end
  end

  def self.unique_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "好"              then Hao3Word.new(term, pos)  # "hảo"
    when "上"              then ShangWord.new(term, pos) # "thượng"
    when "中"              then ZhongWord.new(term, pos) # "trung"
    when "下"              then XiaWord.new(term, pos)   # "hạ"
    when .ends_with?('是') then VShiWord.new(term, pos)  # "thị"
    when .ends_with?('有') then VYouWord.new(term, pos)  # "hữu"
    else                       UniqWord.new(term, pos)
    end
  end

  def self.phrase_from_term(term : V2Term, pos : Int32 = 0)
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
