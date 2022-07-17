require "../v2dict"
require "./mt_node/*"

module MtlV2::AST
  def self.from_char(char : Char, idx = 0)
    case char
    when ' '
      Wspace.new(" ", idx: idx)
    when '_', .alphanumeric?
      Litstr.new(char, idx)
    else
      BaseWord.new(char, idx)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.from_term(term : V2Term)
    case term.tags[0][0]?
    when 'N' then name_from_term(term)
    when 'n' then noun_from_term(term)
    when 'd' then AdvbWord.new(term)
    when 'v' then verb_from_term(term)
    when 'a' then adjt_from_term(term)
    when 'm' then number_from_term(term)
    when 'q' then quanti_from_term(term)
    when 'r' then pronoun_from_term(term)
    when 'p' then prepos_from_term(term)
    when 'k' then suffix_from_term(term)
    when 'c' then conj_from_term(term)
    when '!' then special_from_term(term)
    when 'x' then literal_from_term(term)
    when '~' then extra_from_term(term)
    when 'w' then punct_from_term(term)
    when 'u' then ptcl_from_term(term)
    else          BaseWord.new(term)
    end
  end

  def self.number_from_term(term : V2Term)
    return NquantWord.new(term) if term.tags[0] == "mq"

    case
    when NdigitWord.matches?(term.key) then NdigitWord.new(term)
    when NhanziWord.matches?(term.key) then NhanziWord.new(term)
    else                                    NumberWord.new(term)
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
end
