module MT::PosTag
  def self.map_literal(tag : String)
    case tag[1]?
    when 'i' then make(:lit_idiom, MtlPos.flags(Object, Ktetic))
    when 'q' then make(:lit_quote, MtlPos.flags(Object, Ktetic))
    when 't' then make(:lit_trans, MtlPos.flags(Object, Ktetic))
    else          make(:lit_blank, MtlPos.flags(Object, Ktetic))
    end
  end

  def self.map_strings(key : String = "")
    case key
    when .starts_with?('#')    then make(:str_hash, :object)
    when .starts_with?("http") then make(:str_link, :object)
    when .starts_with?("www.") then make(:str_link, :object)
    when .includes?("@")       then make(:str_mail, :object)
    when .matches?(/[\w\d]/)   then make(:str_other, :object)
    else                            make(:str_emoji, :object)
    end
  end
end
