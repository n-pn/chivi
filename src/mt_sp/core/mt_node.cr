require "./mt_prop"

struct SP::MtNode
  getter val : String
  property idx : Int32 = 0

  getter size : Int32
  getter prop : MtProp

  getter cost : Int32 = 0

  NONE = new(val: "", idx: 0, size: 0, prop: MtProp.flags(NoSpaceL, NoSpaceR))

  BASE_COST = 64

  def initialize(@val, @size, @idx = 0, @prop : MtProp = :content)
    @cost = size &* BASE_COST &+ size &** size
  end

  def initialize(char : Char, @idx)
    @val = char.to_s
    @size = 1
    @prop = MtProp.map(char)
    @cost = 65
  end

  def dup!(idx = @idx) : self
    clone = self.dup
    clone.idx = idx
    clone
  end

  def to_txt(io : IO, cap : Bool = false) : Bool
    io << cap_val(cap)
    !@prop.content? && cap || prop.cap_after?
  end

  def to_mtl(io : IO, cap : Bool = false) : Bool
    io << '\t' << cap_val(cap)

    dic = @prop.content? ? 1 : 0
    io << 'ǀ' << dic << 'ǀ' << @idx << 'ǀ' << @size
    !@prop.content? && cap || prop.cap_after?
  end

  def cap_val(cap : Bool = true)
    return @val unless cap && @prop.content?

    String.build(@val.bytesize) do |io|
      @val.each_char_with_index do |char, i|
        io << (i == 0 ? char.upcase : char)
      end
    end
  end
end
