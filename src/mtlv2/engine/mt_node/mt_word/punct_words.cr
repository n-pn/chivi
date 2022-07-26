require "../mt_base/*"

module MtlV2::MTL
  # ## generic

  module Boundary
  end

  class PunctWord < BaseWord
    def cap_after?(cap : Bool) : Bool
      cap
    end
  end

  # #### end sentence

  class StopMark < PunctWord
    include Boundary

    def add_space?(prev : MtNode?)
      false
    end

    def cap_after?(cap : Bool) : Bool
      true
    end
  end

  # class DeciStop < StopMark
  # end

  class ExclMark < StopMark
  end

  class QuesMark < StopMark
  end

  # ### open nested structure

  module OpenPunct
    getter match_char : Char { @val[0] }
  end

  class OpenQuote < PunctWord
    include OpenPunct

    getter match_char : Char do
      case char = @val[0]
      when '“' then '”'
      when '‘' then '’'
      else          char
      end
    end
  end

  class OpenTitle < PunctWord
    include OpenPunct

    # NOTE:
    # 〈	‹
    # 〉	›

    getter match_char : Char do
      case char = @val[0]
      when '⟨' then '⟩'
      when '<' then '>'
      when '‹' then '›'
      else          char
      end
    end
  end

  class OpenParenth < PunctWord
    include OpenPunct

    getter match_char : Char do
      case char = @val[0]
      when '(' then ')'
      else          char
      end
    end
  end

  class OpenBracket < PunctWord
    include OpenPunct

    getter match_char : Char do
      case char = @val[0]
      when '[' then ']'
      when '{' then '}'
      else          char
      end
    end
  end

  # ######### close nested structure

  module ClosePunct
    getter match_char : Char { @val[0] }

    def add_space?(prev : MtNode?)
      false
    end
  end

  class CloseQuote < PunctWord
  end

  class CloseTitle < PunctWord
  end

  class CloseParenth < PunctWord
  end

  class CloseBracket < PunctWord
  end

  # ## both open and close
  class DoubleQuote < PunctWord
    include OpenPunct
    include ClosePunct

    getter match_char = '"'
  end

  # ########### inner sentence

  class Wspace < PunctWord
    def add_space?(prev : MtNode?)
      false
    end
  end

  class Middot < PunctWord
  end

  class Comma < PunctWord
    def add_space?(prev : MtNode?)
      false
    end
  end

  class Cenum < PunctWord
    def add_space?(prev : MtNode?)
      false
    end

    def to_txt(io : IO) : Nil
      io << ','
    end

    def to_mtl(io : IO) : Nil
      io << ','
    end
  end

  class Colon < PunctWord
    include Boundary

    def cap_after?(cap : Bool) : Bool
      true
    end
  end

  class Smcln < PunctWord
    include Boundary
  end

  class Ellips < PunctWord
  end

  class Atsign < PunctWord
  end

  class DashMark < PunctWord
  end

  class TildeSign < PunctWord
    def add_space?(prev : MtNode?)
      return false unless succ = @succ
      case succ
      when FullStop, StopPunct then false
      else                          true
      end
    end
  end

  # class PlusSign < PunctWord
  # end

  # class MinusSign < PunctWord
  # end

  ######

  module MtNode
    def add_space?(prev : Wspace)
      false
    end

    def add_space?(prev : Colon)
      true
    end
  end
end
