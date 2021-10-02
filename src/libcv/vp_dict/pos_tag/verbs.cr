struct CV::PosTag
  VERBS = {
    # 动词 - verb - động từ
    {"v", "Verb", Pos::Verbs & Pos::Contws},
    # 副动词 - adverbial use of verb - ?
    {"vd", "Vead", Pos::Verbs & Pos::Contws},
    # 名动词 - nominal use of verb - danh động từ
    {"vn", "Veno", Pos::Verbs & Pos::Nouns & Pos::Contws},

    # 趋向动词 - directional verb
    {"vf", "Vdir", Pos::Verbs & Pos::Contws},
    # 形式动词 - pro-verb - động từ hình thái
    {"vx", "Vpro", Pos::Verbs & Pos::Contws},

    # 不及物动词（内动词）- intransitive verb - nội động từ
    {"vi", "Vintr", Pos::Verbs & Pos::Contws},
    # 动词性惯用语 - verbal formulaic expression
    {"vl", "Vform", Pos::Verbs & Pos::Contws},
    # 动词性语素 - verbal morpheme
    {"vg", "Vmorp", Pos::Verbs & Pos::Contws},

    # 动词 “是” - động từ `thị`
    {"vshi", "Vshi", Pos::Verbs & Pos::Uniqs & Pos::Contws},
    # 动词 “有” - động từ `hữu`
    {"vyou", "Vyou", Pos::Verbs & Pos::Uniqs & Pos::Contws},
    # 动词 “会” - động từ `hội`
    {"vhui", "Vhui", Pos::Verbs & Pos::Uniqs & Pos::Contws},
    # 动词 “能” - động từ `năng`
    {"vneng", "Vneng", Pos::Verbs & Pos::Uniqs & Pos::Contws},
    # 动词 “想” - động từ `tưởng`
    {"vxiang", "Vxiang", Pos::Verbs & Pos::Uniqs & Pos::Contws},
  }

  @[AlwaysInline]
  def verbs?
    @pos.verbs?
  end
end
