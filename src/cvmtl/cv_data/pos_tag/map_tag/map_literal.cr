module MT::PosTag
  def self.map_literal(tag : String, str : String)
    case tag[1]?
    when 'v' then make(:sep_verb)
    when 'o' then make(:sep_objt)
    when 'i' then make(:lit_idiom)
    when 'q' then make(:lit_quote)
    when 't' then make(:lit_trans)
    when 'e' then make(:str_emoji)
    when 'x' then make(:str_other)
    when 'u' then make(:str_link)
    when 'w' then map_puncts(str)
    else          map_string(str)
    end
  end

  def self.map_string(str : String = "")
    case str
    when .starts_with?('#')    then make(:str_hash, :object)
    when .starts_with?("http") then make(:str_link, :object)
    when .starts_with?("www.") then make(:str_link, :object)
    when .includes?("@")       then make(:str_mail, :object)
    when .matches?(/[\w\d]/)   then make(:str_other, :object)
    else                            make(:lit_blank, :object)
    end
  end

  def self.map_puncts(str : String)
    {% begin %}
      case str
    {% lines = read_file("#{__DIR__}/../mtl_tag/12-puncts.tsv").split("\n") %}
    {% for line in lines.select { |x| !x.empty? && !x.starts_with?('#') } %}
      {% _short, tag, pos, keys = line.split('\t') %}
      when {{keys.id}} then {MtlTag::{{tag.id}}, MtlPos.flags(Unreal, {{pos.id}})}
    {% end %}
      else {MtlTag::Pmark, MtlPos.flags(Unreal, Boundary)}
      end
    {% end %}
  end
end
