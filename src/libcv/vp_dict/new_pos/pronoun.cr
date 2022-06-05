require "./_base"

module CV::POS
  PROPOS = Pos.flags(Pronouns, Contws)

  # 代词 - pronoun - đại từ chưa phân loại
  struct Pronoun < Objects; end

  # 人称代词 - personal pronoun - đại từ nhân xưng
  struct PerPron < Pronoun; end

  # 指示代词 - demonstrative pronoun - đại từ chỉ thị
  struct DemPron < Pronoun; end

  struct ProZhe < DemPron; end

  struct ProNa1 < DemPron; end

  struct ProJi < DemPron; end

  # 疑问代词 - interrogative pronoun - đại từ nghi vấn
  struct IntPron < Pronoun; end

  struct ProNa2 < IntPron; end

  def self.init_pronoun(tag : String, key : String)
    case tag[1]?
    when 'z' then init_prodem(key)
    when 'y' then init_proint(key)
    when 'r' then PerPron.new
    else          Pronoun.new
    end
  end

  def self.init_prodem(key : String)
    case key
    when "这" then ProZhe.new
    when "那" then ProNa1.new
    when "几" then ProJi.new
    else          DemPron.new
    end
  end

  def self.parse_proint(key : String)
    case key
    when "哪" then ProNa2.new
    else          IntPron.new
    end
  end
end
