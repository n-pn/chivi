require "./mtl_pos"
require "./mtl_tag"

struct CV::PosTag
  macro pos(*values)
    {% for value, i in values %}\
    {% if i != 0 %} | {% end %}\
    MtlTag::{{ value }}{% end %}\
  end

  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  LitBlank = new(:lit_blank, :none)
  LitTrans = new(:lit_trans, :none)

  getter pos : MtlPos
  getter tag : MtlTag
  forward_missing_to tag

  def initialize(@tag : MtlTag = :lit_blank, @pos : MtlPos = :none)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.parse(tag : String, key : String = "", val : String = "") : self
    case tag[0]?
    when nil then LitTrans
    when 'N' then parse_name(tag, key)
    when 'n' then parse_noun(tag, key)
    when 'v' then parse_verb(tag, key)
    when 'a' then parse_adjt(tag, key)
    when 'u' then parse_ptcl(key)
    when 'p' then parse_prepos(key)
    when 'd' then parse_adverb(key)
    when 'm' then parse_number(tag, key)
    when 'q' then parse_quanti(key)
    when 'k' then parse_suffix(tag, key, val)
    when 'r' then parse_pronoun(tag, key)
    when 'x' then parse_string(tag)
    when '-' then parse_literal(tag)
    when '!' then parse_singular(key)
    when '~' then parse_polysemy(key)
    when '+' then parse_phrase(tag)
    when 'w' then parse_punct(val)
    else          parse_other(tag)
    end
  end
end

require "./map_tag/*"

# puts CV::PosTag.parse("n").tag
# puts CV::PosTag.parse("na").tag
# puts CV::PosTag.parse("vm", "").tag
# puts CV::PosTag.parse("vd").tag
# puts CV::PosTag.parse("w", "﹑").tag
# puts CV::PosTag.parse("w", ":").tag
# puts CV::PosTag.parse("w", "：").tag
# puts CV::PosTag.parse("vm", "会").tag
# puts CV::PosTag.parse("w", "《").tag
# puts CV::PosTag.parse("w", "“").tag
