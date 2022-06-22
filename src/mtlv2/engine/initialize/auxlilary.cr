module CV::POS
  class Auxil < BaseNode; end

  class Ule < Auxil; end

  class Uzhi < Auxil; end

  class Uzhe < Auxil; end

  class Uguo < Auxil; end

  class Usuo < Auxil; end

  #############

  class Ude1 < Auxil; end

  class Ude2 < Auxil; end

  class Ude3 < Auxil; end

  #############

  class Udeng < Auxil; end

  class Udeng1 < Uyy; end

  class Udeng2 < Uyy; end

  ##########

  class Uyy < Auxil; end

  #####

  class Udh < Auxil; end

  class Uls < Auxil; end

  class Ulian < Auxil; end

  #########

  # ameba:disable Metrics/CyclomaticComplexity
  def self.auxil_from_term(term : V2Term)
    case key
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
    else                             Auxil.new(term)
    end
  end
end
