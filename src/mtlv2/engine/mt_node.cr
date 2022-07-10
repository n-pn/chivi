require "../v2dict"
require "./mt_node/*"

module MtlV2::AST
  # ameba:disable Metrics/CyclomaticComplexity
  def self.from_term(term : V2Term)
    case term.tags[0][0]?
    when 'n' then noun_from_term(term)
    when 'v' then verb_from_term(term)
    when 'a' then adjt_from_term(term)
    when 'd' then adverb_from_term(term)
    when 'm' then number_from_term(term)
    when 'q' then quanti_from_term(term)
    when 'r' then pronoun_from_term(term)
    when 'f' then locat_from_term(term)
    when 'w' then punct_from_term(term)
    when 'u' then auxil_from_term(term)
    when 'p' then prepos_from_term(term)
    when 'k' then suffix_from_term(term)
    when 'c' then conjunct_from_term(term)
    when '!' then special_from_term(term)
    when 'x' then literal_from_term(term)
    when '~' then extra_from_term(term)
    when '-' then BaseNode.new(term)
    when nil then UnknNode.new(term)
    else          other_from_term(term)
    end
  end

  def self.from_char(char : Char, idx = 0)
    case char
    when ' '
      Punct.new(char, idx)
    when '_', .alphanumeric?
      Litstr.new(char, idx)
    else
      BaseNode.new(char, idx)
    end
  end
end
