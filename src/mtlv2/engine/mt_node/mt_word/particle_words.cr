require "../mt_base/*"

module MtlV2::MTL
  class PtclWord < BaseWord
  end

  class PtclLe < PtclWord
  end

  class PtclZhi < PtclWord
  end

  class PtclZhe < PtclWord
  end

  class PtclGuo < PtclWord
  end

  class PtclSuo < PtclWord
  end

  class PtclDe1 < PtclWord
  end

  class PtclDe2 < PtclWord
  end

  class PtclDe3 < PtclWord
  end

  class PtclDeng < PtclWord
  end

  class PtclDehua < PtclWord
  end

  class PtclYy < PtclWord
  end

  class PtclLs < PtclWord
  end

  class PtclLian < PtclWord
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.ptcl_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "了", "喽"               then PtclLe.new(term, pos: pos)
    when "之"                    then PtclZhi.new(term, pos: pos)
    when "着"                    then PtclZhe.new(term, pos: pos)
    when "过"                    then PtclGuo.new(term, pos: pos)
    when "的", "底"               then PtclDe1.new(term, pos: pos)
    when "地"                    then PtclDe2.new(term, pos: pos)
    when "得"                    then PtclDe3.new(term, pos: pos)
    when "所"                    then PtclSuo.new(term, pos: pos)
    when "的话"                   then PtclDehua.new(term, pos: pos)
    when "云云", "等", "等等"        then PtclDeng.new(term, pos: pos)
    when "一样", "一般", "似的", "般"  then PtclYy.new(term, pos: pos)
    when "来讲", "来说", "而言", "说来" then PtclLs.new(term, pos: pos)
    when "连"                    then PtclLian.new(term, pos: pos)
    else                             PtclWord.new(term, pos: pos)
    end
  end
end
