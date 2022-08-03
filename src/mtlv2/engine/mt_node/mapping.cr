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
end
