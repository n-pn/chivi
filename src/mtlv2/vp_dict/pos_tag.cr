module CV
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  POS_TAGS = {
    ##################
    # 实词 - thực từ #
    ##################

    :Noun => "n",  # 名词 - noun - danh từ
    :Nper => "nr", # 人名 - person name - tên người
    :Nloc => "ns", # 地名 - location name - địa danh
    :Norg => "nt", # 机构团体名 - organization name - tổ chức

    :Ntitle => "nw", # chức danh, nghề nghiệp, địa vị
    :Nother => "nz", # 其它专名 - other proper noun - tên riêng khác

    :Nform => "nl", # 名词性语素 - nominal formulaic expression
    :Nmorp => "ng", # 名词性语素 - nominal morpheme

    :Time  => "t",  # 时间词 - time word - thời gian
    :Tmorp => "tg", # 时间词性语素 - time word morpheme

    :Place => "s", # 处所词 - place word - nơi chốn
    :Space => "f", # 方位词 - space word - phương vị

    :Verb => "v",  # 动词 - verb - động từ
    :Vead => "vd", # 副动词 - adverbial use of verb - ?
    :Veno => "vn", # 名动词 - nominal use of verb - danh động từ

    :Vshi   => "vshi",   # 动词 “是” - động từ `thị`
    :Vyou   => "vyou",   # 动词 “有” - động từ `hữu`
    :Vhui   => "vhui",   # 动词 “会” - động từ `hội`
    :Vneng  => "vneng",  # 动词 “能” - động từ `năng`
    :Vxiang => "vxiang", # 动词 “想” - động từ `tưởng`

    :Vdir => "vf", # 趋向动词 - directional verb
    :Vpro => "vx", # 形式动词 - pro-verb - động từ hình thái

    :Vintr => "vi", # 不及物动词（内动词）- intransitive verb - nội động từ
    :Vform => "vl", # 动词性惯用语 - verbal formulaic expression
    :Vmorp => "vg", # 动词性语素 - verbal morpheme

    :Adjt => "a",  # 形容词 - adjective - hình dung từ (tính từ)
    :Ajav => "ad", # 副形词 - adverbial use of adjective - phó hình từ (phó + tính từ)
    :Ajno => "an", # 名形词 nominal use of adjective - danh hình từ (danh + tính từ)

    :Aform => "al", # 形容词性惯用语 - adjectival formulaic expression -
    :Amorp => "ag", # 形容词性语素 - adjectival morpheme -

    :Modifier => "b",  # modifier (non-predicate noun modifier) - từ khu biệt
    :Modiform => "bl", # 区别词性惯用语 - noun modifier morpheme

    :Descript => "z", # 状态词 - descriptive word - trạng thái

    :Pronoun => "r",  # 代词 - pronoun - đại từ
    :Propers => "rr", # 人称代词 - personal pronoun - đại từ nhân xưng
    :Prodeic => "rz", # 指示代词 - deictic pronoun - đại từ chỉ thị
    :Prointr => "ry", # 疑问代词 - interrogative pronoun - đại từ nghi vấn
    # :Pronmorp => "rg" # 代词性语素 - pronominal morpheme

    :Number => "m",  # 数词 - numeral - số từ
    :Nquant => "mq", # 数量词 - numeral and quantifier - số + lượng

    :Quanti => "q",  # 量词 - quantifier - lượng từ
    :Qtverb => "qv", # 动量词 - temporal classifier -  lượng động từ
    :Qttime => "qt", # 时量词 - verbal classifier -  lượng từ thời gian

    :Idiom => "i", # 成语 - idiom - thành ngữ
    :Abbre => "j", # 简称 - abbreviation - viết tắt
    :Locut => "l", # 习惯用语 - Locution - quán ngữ

    ################
    # 虚词 - hư từ #
    ###############

    :Adverb => "d", # 副词 - adverb - phó từ (trạng từ)
    # dg adverbial morpheme
    # dl adverbial formulaic expression

    :Prepos => "p",    # 介词 - preposition - giới từ
    :Prepba => "pba",  # 介词 “把” - giới từ `bả`
    :Prebei => "pbei", # 介词 “被” - giới từ `bị`

    :Conjunct => "c",  # 连词 - conjunction - liên từ
    :Concoord => "cc", # 并列连词 - coordinating conjunction - liên từ kết hợp

    :Auxi  => "u",     # 助词 - particle/auxiliary - trợ từ
    :Uzhe  => "uzhe",  # 着
    :Ule   => "ule",   # 了 喽
    :Uguo  => "uguo",  # 过
    :Ude1  => "ude1",  # 的 底
    :Ude2  => "ude2",  # 地
    :Ude3  => "ude3",  # 得
    :Usuo  => "usuo",  # 所
    :Udeng => "udeng", # 等 等等 云云
    :Uyy   => "uyy",   # 一样 一般 似的 般
    :Udh   => "udh",   # 的话
    :Uls   => "uls",   # 来讲 来说 而言 说来
    :Uzhi  => "uzhi",  # 之
    :Ulian => "ulian", # 连 （“连小学生都会”）

    :Interjection  => "e", # 叹词 - interjection/exclamation - thán từ
    :Modalparticle => "y", # 语气词 - modal particle - ngữ khí
    :Onomatopoeia  => "o", # 拟声词 - onomatopoeia - tượng thanh

    :Prefix => "h", # 前缀 - prefix - tiền tố
    :Suffix => "k", # 后缀 - suffix - hậu tố

    :Kmen => "kmen", # hậu tố 们
    :Kshi => "kshi", # hậu tố 时

    :String => "x",  # 字符串 - non-word character string - hư từ khác
    :Artstr => "xx", # 非语素字 - for ascii art like emoji...
    :Urlstr => "xu", # 网址URL - url string

    :Punct   => "w",   # 标点符号 - symbols and punctuations - dấu câu
    :Perct   => "wb",  # percentage and permillle signs: ％ and ‰ of full length; % of half length
    :Comma   => "wd",  # full or half-length comma: `，` `,`
    :Penum   => "wn",  # full-length enumeration mark: `、`
    :Pstop   => "wj",  # full stop of full length: `。`
    :Pdeci   => "wx",  # half stop, decimal
    :Colon   => "wm",  # full or half-length colon: `：`， `:`
    :Smcln   => "wf",  # full or half-length semi-colon: `；`， `;`
    :Ellip   => "ws",  # full-length ellipsis: …… …
    :Pdash   => "wp",  # dash: ——  －－  —— －  of full length; ---  ---- of half length
    :Middot  => "wi",  # interpunct
    :Exmark  => "wt",  # full or half-length exclamation mark: `！` `!`
    :Qsmark  => "ww",  # full or half-length question mark: `？` `?`
    :Symbol  => "wh",  # full or half-length unit symbol ￥ ＄ ￡ ° ℃  $
    :Quoteop => "wyz", # full-length single or double opening quote: “ ‘ 『
    :Quotecl => "wyy", # full-length single or double closing quote: ” ’ 』
    :Brackop => "wkz", # opening brackets: （ 〔 ［ ｛ 【 〖 of full length; ( [ { of half length
    :Brackcl => "wky", # closing brackets: ） 〕 ］ ｝ 】 〗 of full length;  ) ] } of half length
    :Titleop => "wwz", # open title《〈 ⟨
    :Titlecl => "wwy", # close title 》〉⟩
  }
end

# @[Flags]
enum CV::PosTag
  None
  {% for tag in POS_TAGS.keys %}
  {{ tag.id }}
  {% end %}

  @[AlwaysInline]
  def real?
    None <= self <= Locut
  end

  def ends?
    puncts? || interjection?
  end

  def nouns?
    Noun <= self <= Nmorp || veno? || ajno?
  end

  def pronouns?
    Pronoun <= self <= Prointr
  end

  @[AlwaysInline]
  def verbs?
    Verb <= self <= Vmorp
  end

  @[AlwaysInline]
  def adjts?
    Adjt <= self <= Amorp
  end

  def content?
    nouns? || pronoun? || verbs? || adjts? || number? || quanti?
  end

  def function?
    advb? || prep? || conj? || ptcl? || stat? || func?
  end

  @[AlwaysInline]
  def strings?
    String <= self <= Urlstr
  end

  @[AlwaysInline]
  def puncts?
    Punct <= self <= Titlecl
  end

  @[AlwaysInline]
  def numbers?
    Number <= self <= Nquant
  end

  @[AlwaysInline]
  def quantis?
    Quanti <= self <= Qttime
  end

  def to_str : ::String
    {% begin %}
    case self
    {% for tag, name in POS_TAGS %}
    when {{ tag.id }} then {{ name }}
    {% end %}
    else ""
    end
    {% end %}
  end

  def self.from_pfr(tag : ::String)
    case tag
    when "nnt", "nis", "nnd", "ntc", "nf", "nhd", "nit", "nhm", "nmc", "nba",
         "gb", "gc", "gg", "gi", "gm", "gp"
      Noun
    when "nto", "ntu", "ntcb", "nth", "ntcf", "ntch", "nts"
      Norg
    when "nh" then Nper
    when "nx" then Nother
    when "bg" then Modifier
    when "rg" then Propers
    when "ul" then Ule
    when "uj" then Ude1
    when "uv" then Ude2
    when "ud" then Ude3
    when "uz" then Uzhe
    else           from_pku(tag)
    end
  end

  def self.from_pku(tag : ::String)
    # nr1 汉语姓氏
    # nr2 汉语名字
    # nrj 日语人名
    # nrf 音译人名
    # nsf 音译地名
    # rzt 时间指示代词
    # rzs 处所指示代词
    # rzv 谓词性指示代词
    # ryt 时间疑问代词
    # rys 处所疑问代词
    # ryv 谓词性疑问代词
    # dg adverbial morpheme
    # dl adverbial formulaic expression
    case tag
    when "nr1", "nr2", "nrj", "nrf" then Nper
    when "nsf"                      then Nloc
    when "nx"                       then Nother
    when "rzt", "rzs", "rzv"        then Prodeic
    when "ryt", "rys", "ryv"        then Prointr
    when "dl", "dg"                 then Adverb
    else                                 from_str(tag)
    end
  end

  def self.from_paddle(tag : ::String)
    case tag
    # Paddle convention
    when "PER"  then Nper
    when "LOC"  then Nloc
    when "ORG"  then Norg
    when "TIME" then Time
    else             from_str(tag)
    end
  end

  def self.from_str(tag : ::String)
    {% begin %}
    case tag
    when "" then None
    {% for tag, name in POS_TAGS %}
    when {{ name }} then {{ tag.id }}
    {% end %}
    else
      # puts "unknown tag <#{tag}>!"
      None
    end
    {% end %}
  end

  # def self.per_pron?(hanzi : String)
  #   case hanzi
  #   when "我", "你", "您", "他", "她", "它",
  #        "我们", "咱们", "你们", "您们", "他们", "她们", "它们",
  #        "朕", "人家", "老子"
  #     true
  #   else
  #     false
  #   end
  # end
end

# puts CV::VpTags.map_tag("n").to_i
