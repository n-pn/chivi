struct CV::MtlV2::PosTag
  # 后缀 - suffix - hậu tố
  SUFFIXES = {
    {"ka", "SufAdjt", Pos.flags(Adjective, Suffixes, Contws)},
    {"kn", "SufNoun", Pos.flags(Nominal, Suffixes, Contws)},
    {"kv", "SufVerb", Pos.flags(Verbal, Suffixes, Contws)},
    {"k", "SufOther", Pos.flags(Suffixes, Contws)},
  }

  {% for type in SUFFIXES %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  def self.parse_suffix(tag : String)
    case tag[1]?
    when 'a' then SufAdjt
    when 'n' then SufNoun
    when 'v' then SufVerb
    else          SufOther
    end
  end
end
