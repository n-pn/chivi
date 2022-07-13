module MtlV2::AST
  class PtclWord < BaseWord
  end

  class Ule < PtclWord
  end

  class Uzhi < PtclWord
  end

  class Uzhe < PtclWord
  end

  class Uguo < PtclWord
  end

  class Usuo < PtclWord
  end

  class Ude1 < PtclWord
  end

  class Ude2 < PtclWord
  end

  class Ude3 < PtclWord
  end

  class Udeng < PtclWord
  end

  class Udeng1 < PtclWord
  end

  class Udeng2 < PtclWord
  end

  class Uyy < PtclWord
  end

  class Udh < PtclWord
  end

  class Uls < PtclWord
  end

  class Ulian < PtclWord
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.ptcl_from_term(term : V2Term)
    case term.key
    when "了", "喽"               then Ule.new(term)
    when "之"                    then Uzhi.new(term)
    when "着"                    then Uzhe.new(term)
    when "过"                    then Uguo.new(term)
    when "的", "底"               then Ude1.new(term)
    when "地"                    then Ude2.new(term)
    when "得"                    then Ude3.new(term)
    when "所"                    then Usuo.new(term)
    when "云云"                   then Udeng.new(term)
    when "等"                    then Udeng1.new(term)
    when "等等"                   then Udeng2.new(term)
    when "一样", "一般", "似的", "般"  then Uyy.new(term)
    when "的话"                   then Udh.new(term)
    when "来讲", "来说", "而言", "说来" then Uls.new(term)
    when "连"                    then Ulian.new(term)
    else                             PtclWord.new(term)
    end
  end
end
