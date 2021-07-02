module CV
  # source: https://gist.github.com/hankcs/d7dbe79dde3f85b423e4
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

    :Ntitle => "nw", # 作品名 - title name - tác phẩm
    :Nother => "nz", # 其它专名 - other proper noun - tên riêng khác

    :Nform => "nl", # 名词性惯用语 - nominal formulaic expression - ???
    :Nmorp => "ng", # 名词性语素 - nominal morpheme

    :Time  => "t",  # 时间词 - time word - thời gian
    :Tmorp => "tg", # 时间词性语素 - time word morpheme

    :Place => "s", # 处所词 - place word - nơi chốn
    :Space => "f", # 方位词 - space word - phương vị

    :Verb => "v",  # 动词 -  - động từ
    :Vead => "vd", # 副动词 - adverbial use of verb - ?
    :Veno => "vn", # 名动词 - nominal use of verb - danh động từ

    :Vshi => "vshi", # 动词 “是” - động từ `thị`
    :Vyou => "vyou", # 动词 “有” - động từ `hữu`

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
    :Pronper => "rr", # 人称代词 - personal pronoun - đại từ nhân xưng
    :Prondei => "rz", # 指示代词 - deictic pronoun - đại từ chỉ thị
    :Pronint => "ry", # 疑问代词 - interrogative pronoun - đại từ nghi vấn
    # :Pronmorp => "rg" # 代词性语素 - pronominal morpheme

    :Number => "m",  # 数词 - numeral - số từ
    :Nquant => "mq", # 数量词 - numeral and quantifier - số + lượng

    :Quanti => "q",  # 量词 - quantifier - lượng từ
    :Qtverb => "qv", # 动量词 - temporal classifier - lượng từ thời gian
    :Qttime => "qt", # 时量词 - verbal classifier - lượng động từ

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

    :String => "x",  # 字符串 - non-word character string - hư từ khác
    :Artstr => "xx", # 非语素字 - for ascii art like emoji...
    :Urlstr => "xu", # 网址URL - url string

    :Punct   => "w",   # 标点符号 - symbols and punctuations - dấu câu
    :Perct   => "wb",  # percentage and permillle signs: ％ and ‰ of full length; % of half length
    :Comma   => "wd",  # full or half-length comma: `，` `,`
    :Flstop  => "wj",  # full stop of full length: `。`
    :Flenum  => "wn",  # full-length enumeration mark: `、`
    :Colon   => "wm",  # full or half-length colon: `：`， `:`
    :Smcln   => "wf",  # full or half-length semi-colon: `；`， `;`
    :Ellip   => "ws",  # full-length ellipsis: ……  …
    :Pdash   => "wp",  # dash: ——  －－  —— －  of full length; ---  ---- of half length
    :Exmark  => "wt",  # full or half-length exclamation mark: `！` `!`
    :Qsmark  => "ww",  # full or half-length question mark: `？` `?`
    :Symbol  => "wh",  # full or half-length unit symbol ￥ ＄ ￡ ° ℃  $
    :Qteopen => "wyz", # full-length single or double opening quote: “ ‘ 『
    :Qtestop => "wyy", # full-length single or double closing quote: ” ’ 』
    :Brkopen => "wkz", # opening brackets: （ 〔  ［  ｛  《 【  〖 〈 of full length; ( [ { < of half length
    :Brkstop => "wky", # closing brackets: ） 〕  ］ ｝ 》  】 〗 〉of full length;  ) ] } > of half length
  }
end

# @[Flags]
enum CV::PosTag
  None
  {% for tag in POS_TAGS.keys %}
  {{ tag.id }}
  {% end %}

  def nouns?
    Noun <= self <= Nmorp || veno? || ajno?
  end

  def verbs?
    Verb <= self <= Vmorp
  end

  def adjts?
    adjt? || ajav? || ajno?
  end

  def content?
    nouns? || pronoun? || verbs? || adjts? || number? || quanti?
  end

  def function?
    advb? || prep? || conj? || ptcl? || stat? || func?
  end

  def to_str : String
    {% begin %}
    case self
    {% for tag, name in POS_TAGS %}
    when {{ tag.id }} then {{ name }}
    {% end %}
    else ""
    end
    {% end %}
  end

  def self.from_str(tag : String)
    {% begin %}
    case tag
    {% for tag, name in POS_TAGS %}
    when {{ name }} then {{ tag.id }}
    {% end %}
    # nr1 汉语姓氏
		# nr2 汉语名字
		# nrj 日语人名
		# nrf 音译人名
    when "nr1", "nr2", "nrj", "nrf" then Nper
    # nsf 音译地名
    when "nsf" then Nloc
    # 	rzt 时间指示代词
    # 	rzs 处所指示代词
    # 	rzv 谓词性指示代词
    when "rzt", "rzs", "rzv" then Prondei
    # 	ryt 时间疑问代词
    # 	rys 处所疑问代词
    # 	ryv 谓词性疑问代词
    when "ryt", "rys", "ryv" then Pronint
    # Paddle convention
    when "PER" then Nper
    when "LOC" then Nloc
    when "ORG" then Norg
    when "TIME" then Time

    # dg adverbial morpheme
    # dl adverbial formulaic expression
    when "dl", "dg" then Adverb
    # PRF 1998
    when "ul" then Ule
    when "uj" then Ude1
    when "uv" then Ude2
    when "ud" then Ude3
    when "uz" then Uzhe
    else None
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
