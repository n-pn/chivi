struct CV::PosTag
  NOUNS = {
    # 名词 - noun - danh từ chung
    {"n", "Noun", Pos::Nouns | Pos::Contws},
    # 抽象概念 - abstract concept - danh từ trừu tượng
    # {"nc", "Ncon", Pos::Nouns | Pos::Contws},

    # 名词性语素 - nominal formulaic expression
    {"nl", "Nform", Pos::Nouns | Pos::Contws},
    # 名词性语素 - nominal morpheme
    {"ng", "Nmorp", Pos::Nouns | Pos::Contws},

    # 人名 - person name - tên người
    {"nr", "Person", Pos::Nouns | Pos::Human | Pos::Names | Pos::Contws},
    # 姓氏 - family name - dòng họ
    # {"nf", "Linage", Pos::Nouns | Pos::Human | Pos::Names | Pos::Contws},

    # 地名 - location name - địa danh |  机构团体名 - organization name - tổ chức
    {"nn", "Naffil", Pos::Nouns | Pos::Names | Pos::Contws},

    # 其它专名 - other proper noun - tên riêng khác
    {"nz", "Nother", Pos::Nouns | Pos::Names | Pos::Contws},

    # danh xưng: chức danh, nghề nghiệp, địa vị
    {"nw", "Ptitle", Pos::Nouns | Pos::Human | Pos::Contws},

    # attributes
    {"na", "Nattr", Pos::Nouns | Pos::Contws},

    # noun phrase
    {"np", "NounPhrase", Pos::Nouns | Pos::Contws},

  }

  NOUNS_2 = {
    # 时间词性语素 - time word morpheme
    {"tg", "Tmorp", Pos::Nouns | Pos::Contws},

    # 处所词 - place word - nơi chốn
    {"s", "Place", Pos::Nouns | Pos::Contws},
    # 方位词 - space word - phương vị
    {"f", "Space", Pos::Nouns | Pos::Contws},

    # 时间词 - time word - thời gian
    {"t", "Time", Pos::Nouns | Pos::Times | Pos::Contws},

  }

  {% for type in NOUNS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  {% for type in NOUNS_2 %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  @[AlwaysInline]
  def places?
    @tag.naffil? || @tag.place?
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.parse_noun(tag : String, key : String)
    case tag[1]?
    when nil then Noun
    when 'g' then Noun
    when 'l' then Nform
    when 'a' then Nattr
    when 'r' then Person
    when "f" then Person
    when 'z' then Nother
    when 'w' then Ptitle
    when 'n' then Naffil
    when 's' then Naffil
    when 't' then Naffil
    when 'p' then NounPhrase
    else          Noun
    end
  end
end
