module MT::PosTag
  def self.map_literal(tag : String)
    case tag[1]?
    when 'i' then make(:lit_idiom, MtlPos.flag(Object))
    when 'q' then make(:lit_quote, MtlPos.flag(Object))
    when 't' then make(:lit_trans, MtlPos.flag(Object))
    else          make(:lit_blank, MtlPos.flag(Object))
    end
  end

  StrHash  = make(:str_hash, MtlPos.flag(Object, Ktetic))
  StrLink  = make(:str_link, MtlPos.flag(Object, Ktetic))
  StrMail  = make(:str_mail, MtlPos.flag(Object, Ktetic))
  StrEmoji = make(:str_emoji, MtlPos.flag(Object, Ktetic))
  StrOther = make(:str_other, MtlPos.flag(Object, Ktetic))

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
