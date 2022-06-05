require "./_base"

module CV::POS
  struct Adverb < ContentWord; end

  struct AdvBu4 < Adverb; end

  struct AdvFei < Adverb; end

  struct AdvMei < Adverb; end

  #########

  ##################

  def self.init_adverb(key : String)
    case key
    when "不" then AdvBu4.new
    when "没" then AdvMei.new
    when "非" then AdvFei.new
    else          Adverb.new
    end
  end
end
