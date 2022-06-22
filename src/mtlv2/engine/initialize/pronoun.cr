module MtlV2::AST
  # 代词 - pronoun - đại từ chưa phân loại
  class Pronoun < Objects; end

  # 人称代词 - personal pronoun - đại từ nhân xưng
  class PerPron < Pronoun; end

  # 指示代词 - demonstrative pronoun - đại từ chỉ thị
  class DemPron < Pronoun; end

  class ProZhe < DemPron; end

  class ProNa1 < DemPron; end

  class ProJi < DemPron; end

  # 疑问代词 - interrogative pronoun - đại từ nghi vấn
  class IntPron < Pronoun; end

  class ProNa2 < IntPron; end

  def self.pronoun_from_term(term : V2Term)
    case term.tags[0][1]?
    when 'z' then prodem_from_term(term)
    when 'y' then proint_from_term(term)
    when 'r' then PerPron.new(term)
    else          Pronoun.new(term)
    end
  end

  def self.prodem_from_term(term : V2Term)
    case term.key
    when "这" then ProZhe.new(term)
    when "那" then ProNa1.new(term)
    when "几" then ProJi.new(term)
    else          DemPron.new(term)
    end
  end

  def self.parse_proint(term : V2Term)
    case term.key
    when "哪" then ProNa2.new(term)
    else          IntPron.new(term)
    end
  end
end
