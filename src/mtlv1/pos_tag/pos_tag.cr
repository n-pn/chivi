require "./mtl_pos"
require "./mtl_tag"

struct CV::PosTag
  def self.load_map(name : String, init_pos : MtlPos = :none)
    lines = File.read_lines("var/cvmtl/mapping/#{name}.tsv")

    output = Hash(String, self).new(initial_capacity: lines.size)

    lines.each_with_object(output) do |line, hash|
      next if line.empty? || line.starts_with?('#')
      args = line.split('\t')
      tag = MtlTag.parse(args[1])

      str = args[2]?.try(&.split(" | "))
      pos = str ? MtlPos.parse(str, init_pos) : init_pos

      hash[args[0]] = new(tag, pos)
    rescue err
      puts [name, line]
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

  property tag : MtlTag
  property pos : MtlPos

  forward_missing_to tag

  def initialize(@tag : MtlTag = :lit_blank, @pos : MtlPos = :none)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init(tag : String, key : String = "", vals = [] of String) : self
    case tag[0]?
    when nil then LitTrans
    when 'N' then map_name(tag, key)
    when 'n' then map_noun(tag, key, vals)
    when 't' then map_tword(key)
    when 's' then map_place(key)
    when 'v' then map_verb(tag, key, vals)
    when 'a' then map_adjt(tag, key, vals)
    when 'p' then map_prepos(key)
    when 'd' then map_adverb(key)
    when 'm' then map_number(tag, key)
    when 'q' then map_quanti(key)
    when 'o' then map_sound(key)
    when 'r' then map_pronoun(key)
    when 'k' then map_suffix(key)
    when 'x' then map_strings(key)
    when 'l' then map_literal(tag)
    when 'c' then map_conjunct(key)
    when 'u' then map_particle(key)
    when '!' then map_uniqword(key)
    when '~' then map_polysemy(tag, key)
    when '+' then map_phrase(tag)
    when 'w' then map_punct(vals[0])
    else          LitBlank
    end
  end
end

require "./map_tag/*"

# puts CV::PosTag.init("n").tag
# puts CV::PosTag.init("na").tag
# puts CV::PosTag.init("vm", "").tag
# puts CV::PosTag.init("~vd").tag
# puts CV::PosTag.init("w", "﹑").tag
# puts CV::PosTag.init("w", ":").tag
# puts CV::PosTag.init("w", "：").tag
# puts CV::PosTag.init("v!", "会").tag
# puts CV::PosTag.init("w", "《").tag
# puts CV::PosTag.init("w", "“").tag
