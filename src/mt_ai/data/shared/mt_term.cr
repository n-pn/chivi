require "./mt_attr"
require "./mt_epos"
require "./dict_type"

struct MT::MtTerm
  getter vstr : String
  getter attr : MtAttr

  getter dnum : DictEnum = :autogen_0
  getter fpos : MtEpos = MtEpos::X

  def self.calc_prio(size : Int32, segr = 2_i16, posr = 2_i16)
    segr == 0 ? 0_i16 : size.to_i16 ** 2_i16 &* 100_i16 &+ segr &* 10_i16 &+ posr
  end

  def initialize(char : Char)
    @vstr = char.to_s
    @attr = MtAttr.parse(char)
  end

  def initialize(@vstr, @attr = :none, @dnum = :unknown_0, @fpos = :X)
  end

  # def to_txt(io : IO, apply_cap : Bool, pad_space : Bool)
  #   io << ' ' if pad_space && !(@attr.hide? || @attr.padb?)
  #   render(io, apply_cap, pad_space)
  # end

  # def to_str(io : IO, cap : Bool, pad : Bool)
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

  ###

end
