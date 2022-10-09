struct CV::PosTag
  def self.map_literal(tag : String)
    case tag[1]?
    when 'i' then new(:lit_idiom)
    when 'q' then new(:lit_quote)
    when 't' then new(:lit_trans)
    else          new(:lit_blank)
    end
  end

  StrHash  = new(:str_hash, :ktetic)
  StrLink  = new(:str_link, :ktetic)
  StrMail  = new(:str_mail, :ktetic)
  StrEmoji = new(:str_emoji, :ktetic)
  StrOther = new(:str_other, :ktetic)

  def self.map_strings(key : String = "")
    case key
    when .starts_with?('#')    then StrHash
    when .starts_with?("http") then StrLink
    when .starts_with?("www.") then StrLink
    when .includes?("@")       then StrMail
    when .matches?(/[\w\d]/)   then StrOther
    else                            StrEmoji
    end
  end
end
