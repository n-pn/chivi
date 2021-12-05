struct CV::PosTag
  VERBS = {
    # 动词 - verb - động từ
    {"v", "Verb", Pos::Verbs | Pos::Contws},
    # 名动词 - nominal use of verb - danh động từ
    {"vn", "Veno", Pos::Verbs | Pos::Nouns | Pos::Contws},
    # 副动词 - verb | adverb
    {"vd", "Vead", Pos::Verbs | Pos::Adverbs | Pos::Contws},

    # 趋向动词 - directional verb
    {"vf", "Vdir", Pos::Verbs | Pos::Vdirs | Pos::Contws},
    # 形式动词 - pro-verb - động từ hình thái
    {"vx", "Vpro", Pos::Verbs | Pos::Contws},

    # 不及物动词（内动词）- intransitive verb - nội động từ
    {"vi", "Vintr", Pos::Verbs | Pos::Contws},
    # 动词性语素 - verbal morpheme
    {"vg", "Vmorp", Pos::Verbs | Pos::Contws},
  }
end
