struct CV::PosTag
  NOUNS = {
    # 名词 - noun - danh từ chung
    {"n", "Noun", Pos::Nominal | Pos::Contws},
    # 抽象概念 - abstract concept - danh từ trừu tượng
    # {"nc", "Ncon", Pos::Nominal | Pos::Contws},

    # 名词性语素 - nominal formulaic expression
    {"nl", "Nform", Pos::Nominal | Pos::Contws},

    # 人名 - person name - tên người
    {"nr", "Person", Pos::Nominal | Pos::Human | Pos::Names | Pos::Contws},
    # 姓氏 - family name - dòng họ
    # {"nf", "Linage", Pos::Nominal | Pos::Human | Pos::Names | Pos::Contws},

    # 地名 - location name - địa danh |  机构团体名 - organization name - tổ chức
    {"nn", "Naffil", Pos::Nominal | Pos::Names | Pos::Contws},

    # danh xưng: chức danh, nghề nghiệp, địa vị
    {"nw", "Ptitle", Pos::Nominal | Pos::Human | Pos::Contws},

    # tựa sách
    {"nx", "Btitle", Pos::Nominal | Pos::Names | Pos::Contws},

    # 其它专名 - other proper noun - tên riêng khác
    {"nz", "Nother", Pos::Nominal | Pos::Names | Pos::Contws},

    # attributes
    {"na", "Nattr", Pos::Nominal | Pos::Contws},
  }

  NOUNS_2 = {
    # 处所词 - place word - nơi chốn
    {"s", "Place", Pos::Nominal | Pos::Contws},
    # 方位词 - space word - phương vị
    {"f", "Space", Pos::Nominal | Pos::Contws},
    # 时间词 - time word - thời gian
    {"t", "Time", Pos::Nominal | Pos::Times | Pos::Contws},
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
    when 'f' then Person
    when 'x' then Btitle
    when 'z' then Nother
    when 'w' then Ptitle
    when 'n' then Naffil
    when 's' then Naffil
    when 't' then Naffil
    when 'd' then AdvNoun
    else          Noun
    end
  end
end
