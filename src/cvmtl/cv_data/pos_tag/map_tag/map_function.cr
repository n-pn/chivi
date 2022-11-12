module MT::PosTag
  def self.map_function(tag : String, key : String)
    case tag[1]?
    when 'v' then map_vcompl(key)
    when 'd' then map_adverb(key)
    when 'p' then map_prepos(key)
    when 'u' then map_particle(key)
    when 'o' then make(:onomat)
    when 'e' then make(:interj)
    when 'y' then make(:mopart)
      # when 'c' then map_conjunct(key)
    else tag == "Fcc" ? make(:concoord) : make(:conjunct)
    end
  end

  CONJUNCT_MAP = load_map("map_conj")

  def self.map_conjunct(key : String)
    CONJUNCT_MAP[key]? || make(:conjunct)
  end

  ADVERB_MAP = load_map("map_advb")

  def self.map_adverb(key : String)
    ADVERB_MAP[key]? || make(:adverb)
  end

  def self.map_prepos(str : String)
    {% begin %}
      case str
    {% lines = read_file("#{__DIR__}/mtl_tag/09-prepos.tsv").split("\n") %}
    {% for line in lines.select { |x| !x.empty? && !x.starts_with?('#') } %}
      {% _short, tag, pos, key = line.split('\t') %}
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
      {% _short, tag, pos, key = line.split('\t') %}
      {% if !key.empty? %}
      when {{key.id}} then {MtlTag::{{tag.id}}, MtlPos.flags({{pos.id}})}
      {% end %}
    {% end %}
      else
        # Log.debug { "unknown particle #{str}"}
        {MtlTag::Prepos, MtlPos.flags(Unreal)}
      end
    {% end %}
  end
end
