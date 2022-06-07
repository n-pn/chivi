require "./new_pos"

module CV::POS
  extend self

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init(tag : String, key : String = "", val = [] of String) : self
    case tag[0]?
    when nil then Unkn.new(key)
    when 'n' then init_noun(tag, key)
    when 'v' then init_verb(tag, key, val)
    when 'a' then init_adjt(tag, key)
    when 'd' then init_adverb(key)
    when 'm' then init_number(tag, key)
    when 'q' then init_quanti(key)
    when 'r' then init_pronoun(tag, key)
    when '~' then init_extra(tag)
    when 'f' then init_locat(key)
    when 'w' then init_punct(key)
    when 'u' then init_auxil(key)
    when 'p' then init_prepos(key)
    when 'k' then init_suffix(tag)
    when 'c' then init_conjunct(tag, key)
    when '!' then init_special(tag, key)
    when 'x' then init_other(tag)
    when 'b' then Modi.new(key)
    when 's' then Space.new
    when 't' then Timeword.new
    when '-' then None.new
    else          init_miscs(tag)
    end
  end
end
