module MtlV2::AST
  class Adverb < BaseNode; end

  class AdvBu4 < Adverb; end

  class AdvFei < Adverb; end

  class AdvMei < Adverb; end

  def self.adverb_from_term(term : V2Term)
    case term.key
    when "不" then AdvBu4.new(term)
    when "没" then AdvMei.new(term)
    when "非" then AdvFei.new(term)
    else          Adverb.new(term)
    end
  end
end
