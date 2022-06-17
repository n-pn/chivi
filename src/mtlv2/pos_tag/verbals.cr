struct MtlV2::PosTag
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

  SPECIAL_VERB_FLAGS = Pos.flags(Verbal, Special, Contws)

  VShi = new(Tag::VShi, SPECIAL_VERB_FLAGS)
  VYou = new(Tag::VYou, SPECIAL_VERB_FLAGS)

  V2Object = new(Tag::Verb, SPECIAL_VERB_FLAGS, Sub::V2Object)
  VDircomp = new(Tag::Verb, SPECIAL_VERB_FLAGS, Sub::VDircomp)
  VCombine = new(Tag::Verb, SPECIAL_VERB_FLAGS, Sub::VCombine)
  VCompare = new(Tag::Verb, SPECIAL_VERB_FLAGS, Sub::VCompare)

  # ameba:disable Metrics/CyclomaticComplexity
  def self.parse_verb(tag : String, key : String)
    case tag[1]?
    when nil then Verb
    when 'n' then Veno
    when 'd' then Vead
    when 'i' then Vintr
    when '2' then V2Object
    when 'x' then VCombine
    when 'p' then VCompare
    when 'f' then VDircomp
    when 'o' then VerbObject
    when 'l' then VerbObject
    when 'm' then parse_vmodal(key)
    when '!' then parse_verb_special(key)
    else          Verb
    end
  end

  def self.parse_verb_special(key : String)
    if key.ends_with?('是')
      VShi # "thị"
    elsif key.ends_with?('有')
      VYou # "hữu"
    elsif MtDict.v2_objs.has_key?(key)
      V2Object
    elsif MtDict.verb_dir.has_key?(key)
      VDircomp
    elsif MtDict.v_combine.has_key?(key)
      VCombine
    elsif MtDict.v_compare.has_key?(key)
      VCompare
    else
      Verb
    end
  end
end
