module MtlV2::AST
  class Idiom < BaseNode
  end

  def self.other_from_term(term : V2Term)
    case term.tags[0]
    when "j" then BaseNoun.new(term)
    when "i" then Idiom.new(term)
    when "l" then Idiom.new(term)
    when "z" then Aform.new(term)
    when "e" then Exclam.new(term)
    when "y" then Mopart.new(term)
    when "o" then Onomat.new(term)
    else          Unkn.new(term)
    end
  end
end
