require "./mtl_pos"
require "./mtl_tag"

module MT::PosTag
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  MAP_POS = {} of MtlTag => MtlPos
  MAP_POS[MtlTag::Empty] = MtlPos.flags(Boundary, NoSpaceL, NoSpaceR, CapRelay, Unreal)

  {% begin %}
    {% files = {
         "00-punct",
         "01-literal",
         "02-nominal",
         "03-pronoun",
         "04-numeral",
         "05-verbal",
         "06-adjective",
         "07-adverb",
         "08-conjunct",
         "09-prepos",
         "10-particle",
         "11-phrase",
         "12-soundword",
         "13-morpheme",
         "14-polysemy",
         "15-uniqword",
       } %}
    {% for file in files %}
      {% lines = read_file("#{__DIR__}/mtl_tag/#{file.id}.tsv").split("\n") %}
      {% for line in lines.reject { |x| x.empty? || x.starts_with?('#') } %}
        {% tag, pos = line.split('\t') %}
        MAP_POS[MtlTag::{{tag.id}}] = MtlPos.flags({{pos.id}})
      {% end %}
    {% end %}
  {% end %}

  def self.map_pos(tag : MtlTag)
    MAP_POS[tag] || MtlPos::None
  end

  def self.load_map(name : String) : Hash(String, {MtlTag, MtlPos})
    lines = File.read_lines("var/cvmtl/inits/#{name}.tsv")
    lines.each_with_object({} of String => {MtlTag, MtlPos}) do |line, hash|
      next if line.empty? || line.starts_with?('#')
      args = line.split('\t')

      key = args[0]
      tag = MtlTag.parse(args[1])
      hash[key] = make(tag)
    rescue err
      Log.error(exception: err) { "error parsing #{name} on line: #{line}" }
    end
  end

  def self.make(tag : MtlTag, pos : MtlPos = map_pos(tag))
    {tag, pos}
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init(tag : String, key : String = "", val : String = "", alt : String? = nil)
    case tag[0]?
    when nil then make(:lit_trans)
    when 'N' then map_name(tag, key)
    when 'n' then map_noun(tag, key, alt)
    when 't' then map_tword(key)
    when 's' then map_place(key)
    when 'v' then map_verb(tag, key, !!alt)
    when 'a' then map_adjt(tag, key, !!alt)
    when '~' then map_polysemy(tag, key)
    when '+' then map_phrase(tag)
    when 'p' then map_prepos(key)
    when 'd' then map_adverb(key)
    when 'm' then map_number(tag, key)
    when 'r' then map_pronoun(key)
    when 'q' then map_quanti(key)
    when 'k' then map_suffix(key)
    when 'x' then map_strings(key)
    when 'l' then map_literal(tag)
    when 'c' then map_conjunct(key)
    when 'u' then map_particle(key)
    when '!' then map_uniqword(key)
    when 'y' then map_sound(key)
    when 'w' then map_punct(val)
    else          make(:lit_blank)
    end
  end

  def self.map_punct(str : String)
    {% begin %}
      case str
    {% lines = read_file("#{__DIR__}/mtl_tag/00-punct.tsv").split("\n") %}
    {% for line in lines.select { |x| !x.empty? && !x.starts_with?('#') } %}
      {% tag, pos, keys = line.split('\t') %}
      when {{keys.id}} then {MtlTag::{{tag.id}}, MtlPos.flags(Unreal, {{pos.id}})}
    {% end %}
      else {MtlTag::Pmark, MtlPos.flags(Unreal, Boundary)}
      end
    {% end %}
  end

  def self.map_prepos(str : String)
    {% begin %}
      case str
    {% lines = read_file("#{__DIR__}/mtl_tag/09-prepos.tsv").split("\n") %}
    {% for line in lines.select { |x| !x.empty? && !x.starts_with?('#') } %}
      {% tag, pos, key = line.split('\t') %}
      {% if !key.empty? %}
      when {{key.id}} then {MtlTag::{{tag.id}}, MtlPos.flags({{pos.id}})}
      {% end %}
    {% end %}
      else {MtlTag::Prepos, MtlPos.flags(Unreal)}
      end
    {% end %}
  end

  def self.map_particle(str : String)
    {% begin %}
      case str
    {% lines = read_file("#{__DIR__}/mtl_tag/10-particle.tsv").split("\n") %}
    {% for line in lines.select { |x| !x.empty? && !x.starts_with?('#') } %}
      {% tag, pos, key = line.split('\t') %}
      {% if !key.empty? %}
      when {{key.id}} then {MtlTag::{{tag.id}}, MtlPos.flags({{pos.id}})}
      {% end %}
    {% end %}
      else
        Log.info { "unknown particle #{str}"}
        {MtlTag::Prepos, MtlPos.flags(Unreal)}
      end
    {% end %}
  end
end

require "./map_tag/*"
