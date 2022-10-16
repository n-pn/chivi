require "./mtl_pos"
require "./mtl_tag"

module MT::PosTag
  extend self

  def self.load_map(name : String, init_pos : MtlPos = :none)
    lines = File.read_lines("var/cvmtl/inits/#{name}.tsv")

    output = Hash(String, {MtlTag, MtlPos}).new(initial_capacity: lines.size)

    lines.each_with_object(output) do |line, hash|
      next if line.empty? || line.starts_with?('#')
      args = line.split('\t')

      key = args[0]
      tag = MtlTag.parse(args[1])

      str = args[2]?.try(&.split(" | "))
      pos = str ? MtlPos.parse(str, init_pos) : init_pos

      hash[key] = {tag, pos}
    rescue err
      puts [name, line]
    end
  end

  def self.make(tag : MtlTag, pos : MtlPos = :none)
    {tag, pos}
  end

  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  Empty = make(:empty, :boundary)
  Space = make(:space, :boundary)

  LitBlank = make(:lit_blank, :mixedpos)
  LitTrans = make(:lit_trans, :mixedpos)

  ########
  ###

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init(tag : String, key : String = "", val : String = "", alt : String? = nil) : {MtlTag, MtlPos}
    case tag[0]?
    when nil then LitTrans
    when 'N' then map_name(tag, key)
    when 'n' then map_noun(tag, key, alt)
    when 't' then map_tword(key)
    when 's' then map_place(key)
    when 'v' then map_verb(tag, key, !!alt)
    when 'a' then map_adjt(tag, key, !!alt)
    when 'p' then map_prepos(key)
    when 'd' then map_adverb(key)
    when 'm' then map_number(tag, key)
    when 'q' then map_quanti(key)
    when 'e' then map_sound(key)
    when 'r' then map_pronoun(key)
    when 'k' then map_suffix(key)
    when 'x' then map_strings(key)
    when 'l' then map_literal(tag)
    when 'c' then map_conjunct(key)
    when 'u' then map_particle(key)
    when '!' then map_uniqword(key)
    when '~' then map_polysemy(tag, key)
    when '+' then map_phrase(tag)
    when 'w' then map_punct(val)
    else          LitBlank
    end
  end
end

require "./map_tag/*"
