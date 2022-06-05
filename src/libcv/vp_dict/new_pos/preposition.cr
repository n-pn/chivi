module CV::POS
  struct Prepos < FunctionWord; end

  struct PreBa3 < Prepos; end

  struct PreBei < Prepos; end

  struct PreDui < Prepos; end

  struct PreZai < Prepos; end

  struct PreBi3 < Prepos; end

  def self.init_prepos(key : ::String)
    case key
    when "把"  then PreBa3.new
    when "被"  then PreBei.new
    when "对"  then PreDui.new
    when "在"  then PreZai.new
    when "比"  then PreBi3.new
    when "不比" then PreBi3.new
    else           Prepos.new
    end
  end
end
