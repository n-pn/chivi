struct CV::PosTag
  VERBS = {
    # 动词 - verb - động từ
    {"v", "Verb", Pos::Verbal | Pos::Contws},
    # 名动词 - nominal use of verb - danh động từ
    {"vn", "Veno", Pos::Mixed | Pos::Verbal | Pos::Nominal | Pos::Contws},
    # 副动词 - verb | adverb
    {"vd", "Vead", Pos::Mixed | Pos::Verbal | Pos::Adverbial | Pos::Contws},

    # 趋向动词 - directional verb
    {"vf", "Vdir", Pos::Verbal | Pos::Vdirs | Pos::Contws},
    # 形式动词 - pro-verb - động từ hình thái
    {"vx", "Vpro", Pos::Verbal | Pos::Contws},

    # 不及物动词（内动词）- intransitive verb - nội động từ
    {"vi", "Vintr", Pos::Verbal | Pos::Contws},
    # 动词性语素 - verbal morpheme
    # {"vg", "Vmorp", Pos::Verbal | Pos::Contws},

    # verb + object phrase
    {"vo", "VerbObject", Pos::Verbal | Pos::Contws},
  }

  {% for type in VERBS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  def self.parse_verb(tag : String, key : String)
    case tag[1]?
    when nil then Verb
    when 'n' then Veno
    when 'd' then Vead
    when 'f' then Vdir
    when 'x' then Vpro
    when 'i' then Vintr
    when 'l' then VerbObject
    when 'o' then VerbObject
    when 'm' then parse_vmodal(key)
    else          Verb
    end
  end
end
