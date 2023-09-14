require "./mt_attr"

struct MT::MtTerm
  getter vstr : String
  getter attr : MtAttr
  getter lock : Int8

  def initialize(@vstr, @attr = :none, @lock = 1_i8)
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

  def self.from_char(char : Char)
    new(CharUtil.normalize(char).to_s, MtAttr.parse(char), 0_i8)
  end
end
