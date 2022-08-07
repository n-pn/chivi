require "../mt_base/*"
require "./verb_words"
require "./noun_words"

module MtlV2::MTL
  class Hao3Word < BaseWord
  end

  class ShangWord < LocatNoun
  end

  class ZhongWord < LocatNoun
  end

  class XiaWord < LocatNoun
  end

  class UniqWord < BaseWord
  end

  def self.unique_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "好"              then Hao3Word.new(term, pos)  # "hảo"
    when "上"              then ShangWord.new(term, pos) # "thượng"
    when "中"              then ZhongWord.new(term, pos) # "trung"
    when "下"              then XiaWord.new(term, pos)   # "hạ"
    when .ends_with?('是') then VShiWord.new(term, pos)  # "thị"
    when .ends_with?('有') then VYouWord.new(term, pos)  # "hữu"
    else                       UniqWord.new(term, pos)
    end
  end
end
