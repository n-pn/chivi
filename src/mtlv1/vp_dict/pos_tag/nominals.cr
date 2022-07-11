struct CV::PosTag
  NOUNS = {
    # 名词 - noun - danh từ chung
    {"n", "Noun", Pos::Nominal | Pos::Contws},
    # 抽象概念 - abstract concept - danh từ trừu tượng
    # {"nc", "Ncon", Pos::Nominal | Pos::Contws},

    # 名词性语素 - nominal formulaic expression
    {"nl", "Nform", Pos::Nominal | Pos::Contws},

    # danh xưng: chức danh, nghề nghiệp, địa vị
    {"nh", "Honor", Pos::Nominal | Pos::Human | Pos::Contws},
    # 处所词 - place word - nơi chốn
    {"ns", "Posit", Pos::Nominal | Pos::Contws},
    # 方位词 - space word - phương vị
    {"nf", "Locat", Pos::Nominal | Pos::Contws},
    # 时间词 - time word - thời gian
    {"nt", "Ntime", Pos::Nominal | Pos::Contws},
    # attributes
    {"na", "Nattr", Pos::Nominal | Pos::Contws},
  }

  NAMES = {

    # 人名 - person name - tên người
    {"Nr", "Person", Pos::Nominal | Pos::Human | Pos::Names | Pos::Contws},
    # 姓氏 - family name - dòng họ
    # {"nf", "Linage", Pos::Nominal | Pos::Human | Pos::Names | Pos::Contws},

    # 地名 - location name - địa danh |  机构团体名 - organization name - tổ chức
    {"Na", "Naffil", Pos::Nominal | Pos::Names | Pos::Contws},

    # tựa sách
    {"Nw", "Btitle", Pos::Nominal | Pos::Names | Pos::Contws},

    # 其它专名 - other proper noun - tên riêng khác
    {"Nz", "Nother", Pos::Nominal | Pos::Names | Pos::Contws},
  }

  {% for type in NOUNS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  {% for type in NAMES %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  @[AlwaysInline]
  def places?
    @tag.naffil? || @tag.posit?
  end

  def self.parse_noun(tag : String)
    case tag[1]?
    when 'a' then Nattr
    when 't' then Ntime
    when 'd' then AdvNoun
    when 's' then Posit
    when 'f' then Locat
    when 'h' then Honor
    else          Noun
    end
  end

  def self.parse_name(tag : String)
    case tag[1]?
    when 'r' then Person
    when 'a' then Naffil
    when 'w' then Btitle
    else          Nother
    end
  end
end
