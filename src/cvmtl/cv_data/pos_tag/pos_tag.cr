require "./mtl_pos"
require "./mtl_tag"

module MT::PosTag
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  # convert mtl tag to short name for display
  MAP_STR = {} of MtlTag => String

  # map from short name to full name in enum entity
  MAP_TAG = {} of String => MtlTag

  # map from tag enum to part of speech attributes
  MAP_POS = {} of MtlTag => MtlPos

  MAP_POS[MtlTag::Empty] = MtlPos.flags(Boundary, NoSpaceL, NoSpaceR, Unreal)

  {% begin %}
    {% files = {
         "00-grammar",
         "01-literal", "02-nominal", "03-pronoun", "04-numeral",
         "05-verbal", "06-adjective", "07-adverb", "08-conjunct",
         "09-prepos", "10-particle", "11-others", "12-puncts",
       } %}
    {% for file in files %}
      {% lines = read_file("#{__DIR__}/mtl_tag/#{file.id}.tsv").split("\n") %}
      {% for line in lines.reject { |x| x.empty? || x.starts_with?('#') } %}
        {% str, tag, pos = line.split('\t') %}
        MAP_STR[MtlTag::{{tag.id}}] = {{str.stringify}}
        MAP_TAG[{{str.stringify}}] = MtlTag::{{tag.id}}
        MAP_POS[MtlTag::{{tag.id}}] = MtlPos.flags({{pos.id}})
      {% end %}
    {% end %}
  {% end %}

  def self.map_pos(tag : MtlTag)
    MAP_POS[tag]? || MtlPos::None
  end

  # convert from tag enum to shortname
  def self.to_str(tag : MtlTag)
    MAP_STR[tag]
  end

  # convert from user input tag string to real tag string
  #
  # to hide complexity from regular user, some tags will be mapped directly by
  # its content instead.
  def self.map_str(tag : String, key : String, val : String = key)
    return tag unless tag.ends_with?('_')
    MAP_STR[map_tag(tag, key, val)]
  end

  # map tag from tag string and raw input
  # need `val` for punctuation only, should be removed
  def self.map_tag(str : String, key : String, val : String = "")
    MAP_TAG[str]? || map_tag_by_ctx(str, key, val)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.map_tag_by_ctx(tag : String, key : String = "", val : String = "") : MtlTag
    case tag[0]?
    when nil then MtlTag::LitBlank
    when 'E' then map_name(tag, key)
    when 'N' then map_noun(tag, key)
    when 'V' then map_verb(tag, key)
    when 'A' then map_adjt(tag, key)
    when 'R' then map_pronoun(key)
    when 'M' then map_number(tag, key)
    when 'Q' then map_quanti(key)
    when 'F' then map_function(tag, key)
    when 'X' then map_literal(tag, val)
    else          MtlTag::LitTrans
    end
  end

  def self.load_map(name : String) : Hash(String, MtlTag)
    lines = File.read_lines("var/cvmtl/inits/#{name}.tsv")
    lines.each_with_object({} of String => MtlTag) do |line, hash|
      next if line.empty? || line.starts_with?('#')
      key, tag = line.split('\t')
      hash[key] = MtlTag.parse(tag)
    rescue err
      Log.error(exception: err) { "error parsing #{name} on line: #{line}" }
    end
  end

  def self.make(tag : MtlTag, pos : MtlPos = map_pos(tag))
    {tag, pos}
  end
end

require "./map_tag/*"
