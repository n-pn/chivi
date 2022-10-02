require "./mtl_pos"
require "./mtl_tag"

struct CV::PosTag
  def self.load_map(file : String)
    lines = File.read_lines(file)

    output = Hash(String, self).new(initial_capacity: lines.size)

    lines.each_with_object(output) do |line, hash|
      next if line.empty? || line.starts_with?('#')
      args = line.split('\t')
      tag = MtlTag.parse(args[1])

      pos = args[2]?.try { |x| MtlPos.parse(x.split(" | ")) } || MtlPos::None
      hash[args[0]] = new(tag, pos)
    end
  end

  ########

  macro pos(*values)
    {% for value, i in values %}\
    {% if i != 0 %} | {% end %}\
    MtlPos::{{ value.id }}{% end %}\
  end

  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  Empty = new(:empty)
  Space = new(:space)

  LitBlank = new(:lit_blank, :none)
  LitTrans = new(:lit_trans, :none)

  getter pos : MtlPos
  getter tag : MtlTag
  forward_missing_to tag

  def initialize(@tag : MtlTag = :lit_blank, @pos : MtlPos = :none)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init(tag : String, key : String = "", val : String = "") : self
    case tag[0]?
    when nil then LitTrans
    when 'N' then map_name(tag, key)
    when 'n' then map_noun(tag, key)
    when 'v' then map_verb(tag, key)
    when 'a' then map_adjt(tag, key)
    when 'u' then map_ptcl(key)
    when 'p' then map_prepos(key)
    when 'd' then map_adverb(key)
    when 'm' then map_number(tag, key)
    when 'q' then map_quanti(key)
    when 'k' then map_suffix(tag, key, val)
    when 'r' then map_pronoun(tag, key)
    when 'x' then map_strings(tag)
    when 'l' then map_literal(tag)
    when '!' then map_uniqword(key)
    when '~' then map_polysemy(key)
    when '+' then map_phrase(tag)
    when 'w' then map_punct(val)
    else          map_other(tag)
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
