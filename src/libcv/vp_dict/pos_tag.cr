struct CV::PosTag
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  @[Flags]
  enum Pos
    # content words and functional words
    Contws; Funcws

    Puncts

    Nouns; Verbs; Adjts; Pronouns

    Numbers; Quantis; Strings

    Uniqs
  end

  DATA = {
    # 实词 - thực từ #

    # 名词 - noun - danh từ chung
    {"n", "Noun", Pos::Nouns | Pos::Contws},

    # 名词性语素 - nominal formulaic expression
    {"nl", "Nform", Pos::Nouns | Pos::Contws},

    # 名词性语素 - nominal morpheme
    {"ng", "Nmorp", Pos::Nouns | Pos::Contws},

    # danh xưng: chức danh, nghề nghiệp, địa vị
    {"nw", "Ntitle", Pos::Nouns | Pos::Contws},

    # 人名 - person name - tên người
    {"nr", "Nper", Pos::Nouns | Pos::Contws},

    # họ người
    {"nf", "Nsur", Pos::Nouns | Pos::Contws},

    # 地名 - location name - địa danh
    {"ns", "Nloc", Pos::Nouns | Pos::Contws},

    # 机构团体名 - organization name - tổ chức
    {"nt", "Norg", Pos::Nouns | Pos::Contws},

    # 其它专名 - other proper noun - tên riêng khác
    {"nz", "Nother", Pos::Nouns | Pos::Contws},

    # 时间词 - time word - thời gian
    {"t", "Time", Pos::Nouns | Pos::Contws},

    # 时间词性语素 - time word morpheme
    {"tg", "Tmorp", Pos::Nouns | Pos::Contws},

    # 处所词 - place word - nơi chốn
    {"s", "Place", Pos::Nouns | Pos::Contws},
    # 方位词 - space word - phương vị
    {"f", "Space", Pos::Nouns | Pos::Contws},

    # 动词 - verb - động từ
    {"v", "Verb", Pos::Verbs | Pos::Contws},
    # 副动词 - adverbial use of verb - ?
    {"vd", "Vead", Pos::Verbs | Pos::Contws},
    # 名动词 - nominal use of verb - danh động từ
    {"vn", "Veno", Pos::Verbs | Pos::Nouns | Pos::Contws},

    {"vf", "Vdir", Pos::Verbs | Pos::Contws}, # 趋向动词 - directional verb
    {"vx", "Vpro", Pos::Verbs | Pos::Contws}, # 形式动词 - pro-verb - động từ hình thái

    {"vi", "Vintr", Pos::Verbs | Pos::Contws}, # 不及物动词（内动词）- intransitive verb - nội động từ
    {"vl", "Vform", Pos::Verbs | Pos::Contws}, # 动词性惯用语 - verbal formulaic expression
    {"vg", "Vmorp", Pos::Verbs | Pos::Contws}, # 动词性语素 - verbal morpheme

    # 动词 “是” - động từ `thị`
    {"vshi", "Vshi", Pos::Verbs | Pos::Uniqs | Pos::Contws},
    # 动词 “有” - động từ `hữu`
    {"vyou", "Vyou", Pos::Verbs | Pos::Uniqs | Pos::Contws},
    # 动词 “会” - động từ `hội`
    {"vhui", "Vhui", Pos::Verbs | Pos::Uniqs | Pos::Contws},
    # 动词 “能” - động từ `năng`
    {"vneng", "Vneng", Pos::Verbs | Pos::Uniqs | Pos::Contws},
    # 动词 “想” - động từ `tưởng`
    {"vxiang", "Vxiang", Pos::Verbs | Pos::Uniqs | Pos::Contws},

    # 形容词 - adjective - hình dung từ (tính từ)
    {"a", "Adjt", Pos::Adjts | Pos::Contws},
    # 副形词 - adverbial use of adjective - phó hình từ (phó + tính từ)
    {"ad", "Ajav", Pos::Adjts | Pos::Contws},
    # 名形词 nominal use of adjective - danh hình từ (danh + tính từ)
    {"an", "Ajno", Pos::Adjts | Pos::Nouns | Pos::Contws},

    # 形容词性惯用语 - adjectival formulaic expression -
    {"al", "Aform", Pos::Adjts | Pos::Contws},
    # 形容词性语素 - adjectival morpheme -
    {"ag", "Amorp", Pos::Adjts | Pos::Contws},

    # adjective "好"
    {"ahao", "Ahao", Pos::Adjts | Pos::Uniqs | Pos::Contws},
    # 状态词 - descriptive word - trạng thái
    {"az", "Adesc", Pos::Adjts | Pos::Contws},

    # modifier (non-predicate noun modifier) - từ khu biệt
    {"b", "Modifier", Pos::Contws},
    # 区别词性惯用语 - noun modifier morpheme
    {"bl", "Modiform", Pos::Contws},

    # 代词 - pronoun - đại từ
    {"r", "Pronoun", Pos::Pronouns | Pos::Contws},
    # 人称代词 - personal pronoun - đại từ nhân xưng
    {"rr", "Propers", Pos::Pronouns | Pos::Contws},
    # 指示代词 - deictic pronoun - đại từ chỉ thị
    {"rz", "Prodeic", Pos::Pronouns | Pos::Contws},
    # 疑问代词 - interrogative pronoun - đại từ nghi vấn
    {"ry", "Prointr", Pos::Pronouns | Pos::Contws},
    # :Pronmorp => "rg"

    # 代词性语素 - pronominal morpheme

    # 数词 - numeral - số từ
    {"m", "Number", Pos::Numbers | Pos::Contws},
    # latin number 0 1 2 .. 9
    {"mx", "Numlat", Pos::Numbers | Pos::Contws},
    # 数量词 - numeral and quantifier - số + lượng
    {"mq", "Nquant", Pos::Numbers || Pos::Quantis | Pos::Contws},

    # 量词 - quantifier - lượng từ
    {"q", "Quanti", Pos::Quantis | Pos::Contws},
    # 动量词 - temporal classifier -  lượng động từ
    {"qv", "Qtverb", Pos::Quantis | Pos::Contws},
    # 时量词 - verbal classifier -  lượng từ thời gian
    {"qt", "Qttime", Pos::Quantis | Pos::Contws},

    # 成语 - idiom - thành ngữ
    {"i", "Idiom", Pos::Contws},
    # 简称 - abbreviation - viết tắt
    {"j", "Abbre", Pos::Contws},
    # 习惯用语 - Locution - quán ngữ
    {"l", "Locut", Pos::Contws},

    # 字符串 - non-word character string - hư từ khác
    {"x", "String", Pos::Strings | Pos::Contws},
    # 网址URL - url string
    {"xu", "Urlstr", Pos::Strings | Pos::Contws},
    # 非语素字 - for ascii art like emoji...
    {"xx", "Artstr", Pos::Strings | Pos::Contws},

    ################
    # 虚词 - hư từ #
    ###############

    {"h", "Prefix", Pos::Funcws}, # 前缀 - prefix - tiền tố
    {"k", "Suffix", Pos::Funcws}, # 后缀 - suffix - hậu tố

    {"kmen", "Kmen", Pos::Funcws}, # hậu tố 们
    {"kshi", "Kshi", Pos::Funcws}, # hậu tố 时

    {"d", "Adverb", Pos::Funcws}, # 副词 - adverb - phó từ (trạng từ)
    # dg adverbial morpheme
    # dl adverbial formulaic expression

    {"p", "Prepos", Pos::Funcws},    # 介词 - preposition - giới từ
    {"pba", "Prepba", Pos::Funcws},  # 介词 “把” - giới từ `bả`
    {"pbei", "Prebei", Pos::Funcws}, # 介词 “被” - giới từ `bị`

    {"c", "Conjunct", Pos::Funcws},  # 连词 - conjunction - liên từ
    {"cc", "Concoord", Pos::Funcws}, # 并列连词 - coordinating conjunction - liên từ kết hợp

    {"u", "Auxi", Pos::Funcws},      # 助词 - particle/auxiliary - trợ từ
    {"uzhe", "Uzhe", Pos::Funcws},   # 着
    {"ule", "Ule", Pos::Funcws},     # 了 喽
    {"uguo", "Uguo", Pos::Funcws},   # 过
    {"ude1", "Ude1", Pos::Funcws},   # 的 底
    {"ude2", "Ude2", Pos::Funcws},   # 地
    {"ude3", "Ude3", Pos::Funcws},   # 得
    {"usuo", "Usuo", Pos::Funcws},   # 所
    {"udeng", "Udeng", Pos::Funcws}, # 等 等等 云云
    {"uyy", "Uyy", Pos::Funcws},     # 一样 一般 似的 般
    {"udh", "Udh", Pos::Funcws},     # 的话
    {"uls", "Uls", Pos::Funcws},     # 来讲 来说 而言 说来
    {"uzhi", "Uzhi", Pos::Funcws},   # 之
    {"ulian", "Ulian", Pos::Funcws}, # 连 （“连小学生都会”）

    {"e", "Interjection", Pos::Funcws},  # 叹词 - interjection/exclamation - thán từ
    {"y", "Modalparticle", Pos::Funcws}, # 语气词 - modal particle - ngữ khí
    {"o", "Onomatopoeia", Pos::Funcws},  # 拟声词 - onomatopoeia - tượng thanh

    {"w", "Punct", Pos::Puncts},     # 标点符号 - symbols and punctuations - dấu câu
    {"wd", "Comma", Pos::Puncts},    # full or half-length comma: `，` `,`
    {"wn", "Penum", Pos::Puncts},    # full-length enumeration mark: `、`
    {"wj", "Pstop", Pos::Puncts},    # full stop of full length: `。`
    {"wx", "Pdeci", Pos::Puncts},    # half stop, decimal `.`
    {"wm", "Colon", Pos::Puncts},    # full or half-length colon: `：`， `:`
    {"ws", "Ellip", Pos::Puncts},    # full-length ellipsis: …… …
    {"wp", "Pdash", Pos::Puncts},    # dash: ——  －－  —— －  of full length; ---  ---- of half length
    {"wti", "Tilde", Pos::Puncts},   # tidle ~
    {"wat", "Atsgn", Pos::Puncts},   # at sign @
    {"wps", "Plsgn", Pos::Puncts},   # plus sign +
    {"wms", "Mnsgn", Pos::Puncts},   # minus sign -
    {"wsc", "Smcln", Pos::Puncts},   # full or half-length semi-colon: `；`， `;`
    {"wpc", "Perct", Pos::Puncts},   # percentage and permillle signs: ％ and ‰ of full length; % of half length
    {"wmd", "Middot", Pos::Puncts},  # interpunct
    {"wex", "Exmark", Pos::Puncts},  # full or half-length exclamation mark: `！` `!`
    {"wqs", "Qsmark", Pos::Puncts},  # full or half-length question mark: `？` `?`
    {"wqt", "Squanti", Pos::Puncts}, # full or half-length unit symbol ￥ ＄ ￡ ° ℃  $
    {"wyz", "Quoteop", Pos::Puncts}, # full-length single or double opening quote: “ ‘ 『
    {"wyy", "Quotecl", Pos::Puncts}, # full-length single or double closing quote: ” ’ 』
    {"wkz", "Brackop", Pos::Puncts}, # opening brackets: （ 〔 ［ ｛ 【 〖 of full length; ( [ { of half length
    {"wky", "Brackcl", Pos::Puncts}, # closing brackets: ） 〕 ］ ｝ 】 〗 of full length;  ) ] } of half length
    {"wwz", "Titleop", Pos::Puncts}, # open title《〈 ⟨
    {"wwy", "Titlecl", Pos::Puncts}, # close title 》〉⟩
  }

  enum Tag
    None; Unkn

    {% for data in DATA %}
    {{ data[1].id }}
    {% end %}
  end

  None = new(Tag::None, Pos::Puncts)
  Unkn = new(Tag::Unkn, Pos::Contws)

  {% for data in DATA %}
    {{ data[1].id }} = new(Tag::{{data[1].id}}, {{data[2]}})
  {% end %}

  getter pos : Pos
  getter tag : Tag
  forward_missing_to tag

  def initialize(@tag = Tag::Unkn, @pos = Pos::Contws)
  end

  @[AlwaysInline]
  def contws?
    @pos.contws?
  end

  @[AlwaysInline]
  def funcws?
    @pos.funcws?
  end

  def ends?
    none? || puncts? || interjection?
  end

  @[AlwaysInline]
  def nouns?
    @pos.nouns?
  end

  def names?
    Tag::Nper <= @tag <= Tag::Nother
  end

  @[AlwaysInline]
  def pronouns?
    @pos.pronouns?
  end

  @[AlwaysInline]
  def verbs?
    @pos.verbs?
  end

  @[AlwaysInline]
  def adjts?
    @pos.adjts?
  end

  def content?
    nouns? || pronoun? || verbs? || adjts? || number? || quanti?
  end

  @[AlwaysInline]
  def conjuncts?
    @tag == Tag::Conjunct || @tag == Tag::Concoord
  end

  @[AlwaysInline]
  def preposes?
    Tag::Prepos <= @tag <= Tag::Prebei
  end

  def function?
    advb? || prep? || conj? || ptcl? || stat? || func?
  end

  @[AlwaysInline]
  def strings?
    @pos.strings?
  end

  @[AlwaysInline]
  def puncts?
    @pos.puncts?
  end

  @[AlwaysInline]
  def numbers?
    @pos.numbers?
  end

  @[AlwaysInline]
  def quantis?
    @pos.quantis?
  end

  def nquants?
    Tag::Number <= @tag <= Tag::Qttime
  end

  def to_str : ::String
    {% begin %}
    case @tag
    {% for data in DATA %}
    when {{ data[1].id }} then {{ data[0] }}
    {% end %}
    else ""
    end
    {% end %}
  end

  def self.from_str(tag : ::String) : self
    {% begin %}
    case tag
    {% for data in DATA %}
    when {{ data[0] }} then {{ data[1].id }}
    {% end %}
    when "z" then Adesc
    when "-" then None
    else  Unkn
    end
    {% end %}
  end
end

# puts CV::VpTags.map_tag("n").to_i
