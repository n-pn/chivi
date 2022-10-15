struct QT::QtNode
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

    @@map = Hash(Char, self).new(initial_capacity: 128)

    # ameba:disable Metrics/CyclomaticComplexity
    def self.map(char : Char)
      @@map[char] ||=
        case char
        when 'a'..'z', 'A'..'Z'           then StrPart | UrlPart
        when '0'..'9', '_'                then IntPart | StrPart | UrlPart
        when .letter?                     then Content
        when ' '                          then NoSpaceL | NoSpaceR
        when '.', '!', '?'                then CapAfter | NoSpaceL | UrlPart
        when '⟨', '<', '‹'                then CapAfter | NoSpaceR
        when '⟩', '>', '›'                then CapAfter | NoSpaceL
        when '“', '‘', '[', '{', '('      then NoSpaceR
        when '”', '’', ']', '}', ')'      then NoSpaceL
        when ',', ';', '…'                then NoSpaceL
        when '\'', '"', '·'               then NoSpaceL | NoSpaceR
        when ':', '%', '~'                then NoSpaceL | UrlPart
        when '#', '$', '@'                then NoSpaceR | UrlPart
        when '+', '-', '=', '/', '&', '*' then NoSpaceL | NoSpaceR | UrlPart
        else                                   None
        end
    end
  end
end
