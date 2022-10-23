module MT::PosTag
  def self.map_literal(tag : String)
    case tag[1]?
    when 'i' then make(:lit_idiom, MtlPos.flags(Object))
    when 'q' then make(:lit_quote, MtlPos.flags(Object))
    when 't' then make(:lit_trans, MtlPos.flags(Object))
    else          make(:lit_blank, MtlPos.flags(Object))
    end
  end

  StrHash  = make(:str_hash, MtlPos.flags(Object, Ktetic))
  StrLink  = make(:str_link, MtlPos.flags(Object, Ktetic))
  StrMail  = make(:str_mail, MtlPos.flags(Object, Ktetic))
  StrEmoji = make(:str_emoji, MtlPos.flags(Object, Ktetic))
  StrOther = make(:str_other, MtlPos.flags(Object, Ktetic))

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
