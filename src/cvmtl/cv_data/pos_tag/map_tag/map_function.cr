module MT::PosTag
  CMPL_MAP  = load_map("map_cmpl")
  CONJ_MAP  = load_map("map_conj")
  ADVB_MAP  = load_map("map_advb")
  AFFIX_MAP = load_map("map_affix")

  def self.map_function(tag : String, key : String) : MtlTag
    case tag[1]?
    when 'v' then map_vcompl(key)
    when 'd' then map_adverb(key)
    when 'p' then map_prepos(key)
    when 'u' then map_particle(key)
    when 'g' then map_affix(key)
    when 'o' then MtlTag::Onomat
    when 'e' then MtlTag::Interj
    when 'y' then MtlTag::Mopart
      # when 'c' then map_conjunct(key)
    else tag == "Fcc" ? MtlTag::Concoord : MtlTag::Conjunct
    end
  end

  def self.map_affix(key : String)
    AFFIX_MAP[key]? || begin
      key[0] == '之' ? MtlTag::SufZhi : MtlTag::SufNoun
    end
  end

  def self.map_vcompl(key : String)
    CMPL_MAP[key]? || MtlTag::Rescmpl
  end

  def self.map_conjunct(key : String)
    CONJ_MAP[key]? || MtlTag::Conjunct
  end

  def self.map_adverb(key : String)
    ADVB_MAP[key]? || MtlTag::Adverb
  end

  def self.map_prepos(str : String)
    {% begin %}
      case str
    {% lines = read_file("#{__DIR__}/../mtl_tag/09-prepos.tsv").split("\n") %}
    {% for line in lines.select { |x| !x.empty? && !x.starts_with?('#') } %}
      {% _short, tag, pos, key = line.split('\t') %}
      {% if !key.empty? %}
      when {{key.id}} then MtlTag::{{tag.id}}
      {% end %}
    {% end %}
      else MtlTag::Prepos
      end
    {% end %}
  end

  def self.map_particle(str : String)
    {% begin %}
      case str
    {% lines = read_file("#{__DIR__}/../mtl_tag/10-particle.tsv").split("\n") %}
    {% for line in lines.select { |x| !x.empty? && !x.starts_with?('#') } %}
      {% _short, tag, pos, key = line.split('\t') %}
      {% if !key.empty? %}
      when {{key.id}} then MtlTag::{{tag.id}}
      {% end %}
    {% end %}
      else MtlTag::Prepos
      end
    {% end %}
  end
end
