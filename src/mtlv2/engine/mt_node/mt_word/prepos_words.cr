require "../mt_base/*"

module MtlV2::MTL
  class PrepWord < BaseWord
  end

  class PrepBa3 < PrepWord
  end

  class PrepBei < PrepWord
  end

  class PrepDui < PrepWord
  end

  class PrepZai < PrepWord
  end

  class PrepBi3 < PrepWord
  end

  # "和"
  class PrepHe2 < PrepWord
  end

  # 跟
  class PrepGen < PrepWord
  end

  ####
  def self.prepos_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "把" then PrepBa3.new(term, pos: pos)
    when "被" then PrepBei.new(term, pos: pos)
    when "对" then PrepDui.new(term, pos: pos)
    when "在" then PrepZai.new(term, pos: pos)
    when "比" then PrepBi3.new(term, pos: pos)
    else          PrepWord.new(term, pos: pos)
    end
  end
end
