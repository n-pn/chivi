require "./_base"

module CV::POS
  struct Auxil < FunctionWord; end

  struct Ule < Auxil; end

  struct Uzhi < Auxil; end

  struct Uzhe < Auxil; end

  struct Uguo < Auxil; end

  struct Usuo < Auxil; end

  #############

  struct Ude1 < Auxil; end

  struct Ude2 < Auxil; end

  struct Ude3 < Auxil; end

  #############

  struct Udeng < Auxil; end

  struct Udeng1 < Uyy; end

  struct Udeng2 < Uyy; end

  ##########

  struct Uyy < Auxil; end

  #####

  struct Udh < Auxil; end

  struct Uls < Auxil; end

  struct Ulian < Auxil; end

  #########

  ##################

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init_auxil(key : String)
    case key
    when "了", "喽"               then Ule.new
    when "之"                    then Uzhi.new
    when "着"                    then Uzhe.new
    when "过"                    then Uguo.new
    when "的", "底"               then Ude1.new
    when "地"                    then Ude2.new
    when "得"                    then Ude3.new
    when "所"                    then Usuo.new
    when "云云"                   then Udeng.new
    when "等"                    then Udeng1.new
    when "等等"                   then Udeng2.new
    when "一样", "一般", "似的", "般"  then Uyy.new
    when "的话"                   then Udh.new
    when "来讲", "来说", "而言", "说来" then Uls.new
    when "连"                    then Ulian.new
    else                             Auxil.new
    end
  end
end
