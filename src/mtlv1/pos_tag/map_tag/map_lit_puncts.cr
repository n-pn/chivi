struct CV::PosTag
  def map_literal(tag : String)
    case tag[1]?
    when 'i' then new(:lit_idiom)
    when 'q' then new(:lit_quote)
    when 't' then new(:lit_trans)
    else          new(:lit_blank) # when 'o'
    end
  end

  def map_strings(key : String = "")
    case key
    when .starts_with?('#')    then new(:str_hash)
    when .starts_with?("http") then new(:str_link)
    when .starts_with?("www.") then new(:str_link)
    when .includes?("@")       then new(:str_mail)
    when .matches?(/[\w\d]/)   then new(:str_other)
    else                            new(:str_emoji)
    end
  end
end
