struct TL::TlNode
  getter val : String
  getter len : Int32
  getter idx : Int32
  getter tag : Tag

  NONE = new(val: "", len: 0, idx: 0, tag: Tag.flags(NoSpaceL, NoSpaceR))

  def initialize(@val, @len, @idx, @tag = Tag::Content)
  end

  def initialize(char : Char, @idx)
    @val = char.to_s
    @len = 1
    @tag = Tag.map(char)
  end

  def to_txt(io : IO, cap : Bool = false) : Bool
    io << cap_val(cap)
    !@tag.content? && cap || tag.cap_after?
  end

  def to_mtl(io : IO, cap : Bool = false) : Bool
    io << '\t' << cap_val(cap)
    io << 'ǀ' << (@tag.content? ? 1 : 0) << 'ǀ' << @idx << 'ǀ' << @len
    !@tag.content? && cap || tag.cap_after?
  end

  def cap_val(cap : Bool = true)
    return @val unless cap && @tag.content?

    String.build(@val.size) do |io|
      io << @val[0].upcase << @val[1..]
    end
  end

  @[Flags]
  enum Tag
    CapAfter

    NoSpaceL
    NoSpaceR

    StrPart
    UrlPart
    IntPart

    Content

    @@known = {
      ' '  => NoSpaceL | NoSpaceR,
      '.'  => CapAfter | NoSpaceL | UrlPart,
      '!'  => CapAfter | NoSpaceL | UrlPart,
      '?'  => CapAfter | NoSpaceL | UrlPart,
      '⟨'  => CapAfter | NoSpaceR,
      '<'  => CapAfter | NoSpaceR,
      '‹'  => CapAfter | NoSpaceR,
      '⟩'  => CapAfter | NoSpaceL,
      '>'  => CapAfter | NoSpaceL,
      '›'  => CapAfter | NoSpaceL,
      '“'  => NoSpaceR,
      '‘'  => NoSpaceR,
      '['  => NoSpaceR,
      '{'  => NoSpaceR,
      '('  => NoSpaceR,
      '”'  => NoSpaceL,
      '’'  => NoSpaceL,
      ']'  => NoSpaceL,
      '}'  => NoSpaceL,
      ')'  => NoSpaceL,
      ','  => NoSpaceL,
      ';'  => NoSpaceL,
      '…'  => NoSpaceL,
      '\'' => NoSpaceL | NoSpaceR,
      '"'  => NoSpaceL | NoSpaceR,
      '·'  => NoSpaceL | NoSpaceR,
      ':'  => NoSpaceL | UrlPart,
      '%'  => NoSpaceL | UrlPart,
      '~'  => NoSpaceL | UrlPart,
      '#'  => NoSpaceR | UrlPart,
      '$'  => NoSpaceR | UrlPart,
      '@'  => NoSpaceR | UrlPart,
      '+'  => NoSpaceL | NoSpaceR | UrlPart,
      '-'  => NoSpaceL | NoSpaceR | UrlPart,
      '='  => NoSpaceL | NoSpaceR | UrlPart,
      '/'  => NoSpaceL | NoSpaceR | UrlPart,
      '&'  => NoSpaceL | NoSpaceR | UrlPart,
      '*'  => NoSpaceL | NoSpaceR | UrlPart,
    }

    def self.map(char : Char)
      case char
      when 'a'..'z', 'A'..'Z' then StrPart | UrlPart
      when '0'..'9', '_'      then IntPart | StrPart | UrlPart
      else                         @@known[char]? || None
      end
    end
  end
end
