require "../../base/*"

struct MT::MtDefn
  def self.calc_prio(size : Int32, prio : Int16 = 5_i16)
    prio == 0 ? 0_i16 : size.to_i16 &* (prio &+ size.to_i16)
  end

  ###

  DEG0 = new(vstr: "", attr: MtAttr[Hide, At_t], dnum: :Root2, fpos: :DEG)
  DEG1 = new(vstr: "của", attr: :at_t, dnum: :Root2, fpos: :DEG)
  DEG2 = new(vstr: "do", attr: :at_t, dnum: :Root2, fpos: :DEG)

  ###

  getter vstr : String

  getter attr : MtAttr = MtAttr::None
  getter dnum : MtDnum = MtDnum::Unkn0

  getter fpos : MtEpos = MtEpos::X

  def initialize(char : Char)
    @vstr = char.to_s
    @attr = MtAttr.parse(char)
  end

  def initialize(@vstr, @attr = :none, @dnum = :unkn0, @fpos = :X)
  end

  def as_any(fpos : MtEpos = @fpos)
    MtDefn.new(vstr: @vstr, attr: :none, dnum: @dnum.as_any, fpos: fpos)
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
