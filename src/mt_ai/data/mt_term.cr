require "./mt_pecs"

struct MT::MtTerm
  getter vstr : String
  getter pecs : MtPecs
  getter _len : Int32 = 0

  def initialize(@vstr, @pecs = :none, @_len = 0)
  end

  @[AlwaysInline]
  def pad_space?(pad : Bool)
    pad && !(@pecs.void? || @pecs.nwsl?)
  end

  # def to_txt(io : IO, apply_cap : Bool, pad_space : Bool)
  #   io << ' ' if pad_space && !(@pecs.void? || @pecs.nwsl?)
  #   render(io, apply_cap, pad_space)
  # end

  def to_str(io : IO, cap : Bool, pad : Bool)
    case
    when @pecs.void?
      # do nothing
    when @pecs.capx?
      io << @vstr
    when !cap || @pecs.ncap?
      io << @vstr
      cap = @pecs.capr?
    else
      @vstr.each_char_with_index { |c, i| io << (i == 0 ? c.upcase : c) }
      cap = @pecs.capr?
    end

    {cap, @pecs.void? ? pad : !@pecs.nwsr?}
  end

  ###

  def self.from_char(char : String)
    new(char.to_s, MtPecs.parse(char), 1)
  end
end
