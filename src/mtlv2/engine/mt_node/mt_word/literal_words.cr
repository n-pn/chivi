require "../mt_base/*"

module MtlV2::MTL
  class IdiomWord < BaseWord
  end

  class Exclam < BaseWord
  end

  class Mopart < BaseWord
  end

  class Onomat < BaseWord
  end

  class RawLit < BaseWord
  end

  class UrlLit < RawLit
  end

  class PreLit < RawLit
  end

  def self.literal_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[1]?
    when 'e' then Exclam.new(term, pos: pos)
    when 'y' then Mopart.new(term, pos: pos)
    when 'o' then Onomat.new(term, pos: pos)
    when 'l' then UrlLit.new(term, pos: pos)
    when 'x' then PreLit.new(term, pos: pos)
    else          RawLit.new(term, pos: pos)
    end
  end
end
