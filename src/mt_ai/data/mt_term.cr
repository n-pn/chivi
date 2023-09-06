require "./mt_prop"

struct MT::MtTerm
  getter vstr : String
  getter prop : MtProp

  def initialize(@vstr, @prop = :none)
  end

  # def to_txt(io : IO, apply_cap : Bool, pad_space : Bool)
  #   io << ' ' if pad_space && !(@prop.hide? || @prop.padb?)
  #   render(io, apply_cap, pad_space)
  # end

  # def to_str(io : IO, cap : Bool, pad : Bool)
  #   case
  #   when @prop.hide?
  #     # do nothing
  #   when @prop.capx?
  #     io << @vstr
  #   when !cap || @prop.asis?
  #     io << @vstr
  #     cap = @prop.capn?
  #   else
  #     @vstr.each_char_with_index { |c, i| io << (i == 0 ? c.upcase : c) }
  #     cap = @prop.capn?
  #   end

  #   {cap, @prop.hide? ? pad : !@prop.padn?}
  # end

  ###

  def self.from_char(char : Char)
    new(CharUtil.normalize(char).to_s, MtProp.parse(char))
  end
end
