module MT::PosTag
  def self.map_literal(tag : String, str : String)
    case tag[1]?
    when 'v' then MtlTag::SepVerb
    when 'o' then MtlTag::SepObjt
    when 'i' then MtlTag::LitIdiom
    when 'q' then MtlTag::LitQuote
    when 't' then MtlTag::LitTrans
    when 'e' then MtlTag::StrEmoji
    when 'x' then MtlTag::StrOther
    when 'u' then MtlTag::StrLink
    when 'w' then map_puncts(str)
    else          map_string(str)
    end
  end

  def self.map_string(str : String = "")
    case str
    when .starts_with?('#')    then MtlTag::StrHash
    when .starts_with?("http") then MtlTag::StrLink
    when .starts_with?("www.") then MtlTag::StrLink
    when .includes?("@")       then MtlTag::StrMail
    when .matches?(/[\w\d]/)   then MtlTag::StrOther
    else                            MtlTag::LitBlank
    end
  end

  def self.map_puncts(str : String)
    {% begin %}
      case str
    {% lines = read_file("#{__DIR__}/../mtl_tag/12-puncts.tsv").split("\n") %}
    {% for line in lines.select { |x| !x.empty? && !x.starts_with?('#') } %}
      {% _str, tag, pos, keys = line.split('\t') %}
      when {{keys.id}} then MtlTag::{{tag.id}}
    {% end %}
      else MtlTag::Pmark
      end
    {% end %}
  end
end
