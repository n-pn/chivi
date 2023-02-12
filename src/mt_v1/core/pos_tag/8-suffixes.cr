struct M1::PosTag
  # 后缀 - suffix - hậu tố
  SUFFIXES = {
    {"ka", "SufAdjt", Pos::Suffixes},
    {"kn", "SufNoun", Pos::Suffixes},
    {"kv", "SufVerb", Pos::Suffixes},
    {"k", "Suffix", Pos::Suffixes},
  }

  @[AlwaysInline]
  def suffixes?
    @tag.suf_noun? || @tag.suf_verb? || @tag.suf_adjt?
  end

  {% for type in SUFFIXES %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  def self.parse_suffix(tag : String)
    case tag[1]?
    when 'a' then SufAdjt
    when 'n' then SufNoun
    when 'v' then SufVerb
    else          Suffix
    end
  end
end
