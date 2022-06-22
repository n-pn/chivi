module MtlV2::AST
  class Litstr < BaseNode
  end

  class Urlstr < Litstr
  end

  class Fixstr < Urlstr
  end

  def self.literal_from_term(term : V2Term)
    case term.tags[0][1]?
    when 'x' then Fixstr.new(term)
    when 'l' then Urlstr.new(term)
    else          Litstr.new(term)
    end
  end
end
