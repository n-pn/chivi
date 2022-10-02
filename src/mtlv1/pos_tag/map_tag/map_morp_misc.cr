struct CV::PosTag
  def map_sound(tag : String)
    case tag[1]?
    when 'e' then new(:interj)
    when 'y' then new(:mopart)
    else          new(:onomat) # when 'o'
    end
  end
end
