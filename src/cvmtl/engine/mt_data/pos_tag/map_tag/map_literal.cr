module MT::MapTag
  def self.map_literal(tag : String)
    case tag[1]?
    when 'i' then make(:lit_idiom)
    when 'q' then make(:lit_quote)
    when 't' then make(:lit_trans)
    else          make(:lit_blank)
    end
  end

  StrHash  = make(:str_hash, :ktetic)
  StrLink  = make(:str_link, :ktetic)
  StrMail  = make(:str_mail, :ktetic)
  StrEmoji = make(:str_emoji, :ktetic)
  StrOther = make(:str_other, :ktetic)

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
