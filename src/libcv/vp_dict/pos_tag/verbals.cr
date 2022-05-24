struct CV::PosTag
  VERBS = {
    # 动词 - verb - động từ
    {"v", "Verb", Pos::Verbal | Pos::Contws},
    # 动词性语素 - verbal morpheme
    # {"vg", "Vmorp", Pos::Verbal | Pos::Contws},

    # 名动词 - nominal use of verb - danh động từ
    {"vn", "Veno", Pos.flags(Verbal, Nominal, Mixed, Contws)},

    # 副动词 - verb | adverb
    {"vd", "Vead", Pos.flags(Verbal, Adverbial, Mixed, Contws)},

    # # 趋向动词 - directional verb
    # {"vf", "Vdir", Pos::Verbal | Pos::Vdirs | Pos::Contws},
    # # 形式动词 - pro-verb - động từ hình thái
    # {"vx", "Vpro", Pos::Verbal | Pos::Contws},

    # 不及物动词（内动词）- intransitive verb - nội động từ
    {"vi", "Vintr", Pos.flags(Verbal, V0Obj, Contws)},
    # verb + object phrase
    {"vo", "VerbObject", Pos.flags(Verbal, V0Obj, Contws)},
  }

  {% for type in VERBS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  def self.parse_verb(tag : String, key : String)
    case tag[1]?
    when nil then Verb
    when 'n' then Veno
    when 'd' then Vead
    when 'i' then Vintr
    when 'o' then VerbObject
    when 'l' then VerbPhrase
    when 'm' then parse_vmodal(key)
    when 'f', 'x'
      parse_verb_special(key)
    else Verb
    end
  end
end
