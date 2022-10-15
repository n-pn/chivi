struct QT::QtNode
  getter val : String
  getter len : Int32
  getter idx : Int32
  getter tag : Tag

  NONE = new("", idx: 0, tag: Tag.flags(NoSpaceL, NoSpaceR))

  def initialize(@val, @len, @idx, @tag = Tag::Content)
  end

  def initialize(char : Char, @idx)
    @val = char.to_s
    @len = 1
    @tag = Tag.map(char)
  end

  def to_txt(io : IO, cap : Bool = false) : Bool
    io << (cap && @tag.content? ? @val.capitalize : val)
    tag.cap_after?
  end

  def to_mtl(io : IO, cap : Bool = false) : Bool
    io << '\t' << (cap && @tag.content? ? @val.capitalize : val)
    io << 'ǀ' << (@tag.content? ? 1 : 0) << 'ǀ' << @idx << 'ǀ' << @len
    tag.cap_after?
  end

  @[Flags]
  enum Tag
    CapAfter
    CapRelay

    NoSpaceL
    NoSpaceR

    StrPart
    UrlPart
    IntPart

    Content

    # ameba:disable Metrics/CyclomaticComplexity
    def self.map(char : Char)
      case char
      when 'a'..'z', 'A'..'Z'                then StrPart | UrlPart
      when '0'..'9'                          then IntPart | UrlPart
      when '_'                               then StrPart | UrlPart | IntPart
      when .letter?                          then Content
      when '⟨', '<', '‹'                     then CapAfter | NoSpaceR
      when '⟩', '>', '›'                     then CapAfter | NoSpaceL
      when '“', '‘', '[', '{', '('           then NoSpaceR
      when '”', '’', ']', '}', ')'           then NoSpaceL
      when ',', ';', '…'                     then NoSpaceL
      when '\'', '"', '·'                    then NoSpaceL | NoSpaceR
      when '.', '!', '?'                     then CapAfter | NoSpaceL | UrlPart
      when ':', '%'                          then NoSpaceL | UrlPart
      when '#', '$', '@'                     then NoSpaceR | UrlPart
      when '+', '-', '=', '/', '&', '~', '*' then NoSpaceL | NoSpaceR | UrlPart
      when ' '                               then CapAfter | NoSpaceL | NoSpaceR | StrPart
      else                                        None
      end
    end
  end
end
