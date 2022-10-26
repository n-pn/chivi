struct MT::PosTag
  def self.map_literal(tag : String)
    case tag[1]?
    when 'i' then new(:lit_idiom, MtlPos.flags(Object, Ktetic))
    when 'q' then new(:lit_quote, MtlPos.flags(Object, Ktetic))
    when 't' then new(:lit_trans, MtlPos.flags(Object, Ktetic))
    else          new(:lit_blank, MtlPos.flags(Object, Ktetic))
    end
  end

  def self.map_strings(key : String = "")
    case key
    when .starts_with?('#')    then new(:str_hash, :object)
    when .starts_with?("http") then new(:str_link, :object)
    when .starts_with?("www.") then new(:str_link, :object)
    when .includes?("@")       then new(:str_mail, :object)
    when .matches?(/[\w\d]/)   then new(:str_other, :object)
    else                            new(:str_emoji, :object)
    end
  end
end
