module MtlV2::AST
  class Prepos < BaseNode; end

  class PreBa3 < Prepos; end

  class PreBei < Prepos; end

  class PreDui < Prepos; end

  class PreZai < Prepos; end

  class PreBi3 < Prepos; end

  def self.prepos_from_term(term : V2Term)
    case term.key
    when "把"  then PreBa3.new(term)
    when "被"  then PreBei.new(term)
    when "对"  then PreDui.new(term)
    when "在"  then PreZai.new(term)
    when "比"  then PreBi3.new(term)
    when "不比" then PreBi3.new(term)
    else           Prepos.new(term)
    end
  end
end
