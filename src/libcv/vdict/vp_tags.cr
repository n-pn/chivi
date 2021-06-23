module CV
  VP_TAGS = {
    :Noun => "n",  # danh từ
    :NTit => "nw", # tác phẩm
    :NOth => "nz", # tên riêng khác

    :NPer => "nr", # Địa danh
    :NLoc => "ns", # địa danh
    :NOrg => "nt", # tổ chức

    :NDir => "f", # phương vị
    :Time => "t", # thời gian

    :Verb => "v",  # động từ
    :VCon => "vd", # động từ nối
    :VeNo => "vn", # danh động từ

    :Adje => "a",  # hình dung từ (tính từ)
    :AjAv => "ad", # phó hình từ (trạng tính từ)
    :AjNo => "an", # hình danh từ (danh + tính từ)

    :Number => "m",  # số từ tiếng trung
    :Numlat => "ml", # số từ latin
    :Quanti => "q",  # lượng từ

    :Pronoun => "r",  # đại từ
    :PerPron => "rr", # đại từ nhân xưng
    :PronDem => "rz", # đại từ chỉ thị

    :Adve => "d", # phó từ (trạng từ)
    :Prep => "p", # giới từ
    :Conj => "c", # liên từ
    :Ptcl => "u", # trợ từ

    :Func => "x", # hư từ khác (function word)
    :Punc => "w", # dấu câu
  }
end

@[Flags]
enum CV::VpTags
  {% for tag, name in VP_TAGS %}
  {{ tag.id }}
  {% end %}

  def self.map_tag(tag : String)
    {% begin %}
    case tag
    {% for tag, name in VP_TAGS %}
    when {{ name }} then {{ tag.id }}
    {% end %}
    else None
    end
    {% end %}
  end

  def self.parse(input : String)
    attr = new(0)

    attr |= Noun if input.includes?('N')
    attr |= Verb if input.includes?('V')
    attr |= Adje if input.includes?('A')

    attr
  end

  def self.parse_prio(input : String)
    case input[0]?
    when 'H' then 2
    when 'L' then 0
    else          1
    end
  end

  def self.per_pron?(hanzi : String)
    case hanzi
    when "我", "你", "您", "他", "她", "它",
         "我们", "咱们", "你们", "您们", "他们", "她们", "它们",
         "朕", "人家", "老子"
      true
    else
      false
    end
  end
end

puts CV::VpTags.map_tag("n").to_i
