require "../../base/*"

struct MT::MtDefn
  def self.calc_prio(size : Int32, prio : Int16 = 5_i16)
    prio == 0 ? 0_i16 : size.to_i16 &* (prio &+ size.to_i16)
  end

  ###

  DEG0 = new(vstr: "", attr: MtAttr[Hide, At_t], dnum: :auto_fix, epos: :DEG)
  DEG1 = new(vstr: "của", attr: :at_t, dnum: :auto_fix, epos: :DEG)
  DEG2 = new(vstr: "do", attr: :at_t, dnum: :auto_fix, epos: :DEG)

  ###

  getter vstr : String

  getter attr : MtAttr = MtAttr::None
  getter dnum : MtDnum = MtDnum::UserTmp

  getter epos : MtEpos = MtEpos::X
  getter rank : Int8 = 0_i8

  def initialize(char : Char)
    @vstr = char.to_s
    @attr = MtAttr.parse(char)
  end

  def initialize(@vstr, @attr = :none, @dnum = :user_tmp, @epos = :X, @rank = 0_i8)
  end

  def initialize(rs : DB::ResultSet)
    @vstr = rs.read(String)

    @epos = MtEpos.from_value(rs.read(Int32))
    @attr = MtAttr.from_value(rs.read(Int32))
    @dnum = MtDnum.from_value(rs.read(Int32))
    @rank = rs.read(Int32).to_i8
  end

  def initialize(data : SqDefn)
    @vstr = data.zstr
    @epos = MtEpos.from_value(data.epos)
    @attr = MtAttr.from_value(data.attr)
    @dnum = MtDnum.from_value(data.dnum)
    @rank = data.rank.to_i8
  end

  def as_any(epos : MtEpos = @epos)
    MtDefn.new(vstr: @vstr, attr: :none, dnum: @dnum.as_any, epos: epos)
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
