require "../enum/*"

struct MT::MtDefn
  getter vstr : String
  getter attr : MtAttr

  getter dnum : Int8 = 0_i8
  getter fpos : MtEpos = MtEpos::X

  def self.calc_prio(size : Int32, prio : Int16 = 5_i16)
    prio == 0 ? 0_i16 : size.to_i16 &* (prio &+ size.to_i16)
  end

  def initialize(char : Char)
    @vstr = char.to_s
    @attr = MtAttr.parse(char)
  end

  def initialize(@vstr, @attr = :none, @dnum = :unknown_0, @fpos = :X)
  end

  # def to_txt(io : IO, cap : Bool, und : Bool)
  #   io << ' ' if und && !(@attr.hide? || @attr.padb?)
  #   render(io, cap, und)
  # end

  # def render_vstr(io : IO, cap : Bool, pad : Bool)
  #   case
  #   when @attr.hide?
  #     # do nothing
  #   when @attr.capx?
  #     io << @vstr
  #   when !cap || @attr.asis?
  #     io << @vstr
  #     cap = @attr.capn?
  #   else
  #     @vstr.each_char_with_index { |c, i| io << (i == 0 ? c.upcase : c) }
  #     cap = @attr.capn?
  #   end

  #   {cap, @attr.hide? ? pad : !@attr.padn?}
  # end
end
