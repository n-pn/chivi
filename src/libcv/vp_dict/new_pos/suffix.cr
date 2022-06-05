require "./_base"

module CV::POS
  struct Suffix < ContentWord; end

  struct SufAdjt < Suffix; end

  struct SufNoun < Suffix; end

  struct SufVerb < Suffix; end

  def self.init_suffix(tag : String)
    case tag[1]?
    when 'a' then SufAdjt
    when 'n' then SufNoun
    when 'v' then SufVerb
    else          Suffix
    end
  end
end
