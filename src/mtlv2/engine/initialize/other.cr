module MtlV2::AST
  class Idiom < BaseNode
  end

  class Exclam < BaseNode
  end

  class Mopart < BaseNode
  end

  class Onomat < BaseNode
  end

  def self.other_from_term(term : V2Term)
    case term.tags[0]
    when "i" then Idiom.new(term)
    when "l" then Idiom.new(term)
    when "e" then Exclam.new(term)
    when "y" then Mopart.new(term)
    when "o" then Onomat.new(term)
    else          BaseNode.new(term)
    end
  end
end
