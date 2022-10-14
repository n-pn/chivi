require "../mt_node"
require "../../mt_dict"

class MT::MonoNode < MT::MtNode
  property key : String
  property val : String

  getter alt : String?
  getter dic : Int32

  def initialize(term : MtTerm, @dic = 0, @idx = 0)
    @key = term.key
    @val = term.val
    @alt = term.alt_val

    @tag = term.tag
    @pos = term.pos
  end

  def initialize(@key, @val, @tag : MtlTag, @pos : MtlPos,
                 @dic = 0, @idx = 0, @alt = nil)
  end

  def offset_idx!(start : Int32)
    @idx += start
  end

  def initialize(@key, @val, tag : {MtlTag, MtlPos}, @dic = 0, @idx = 0)
    @tag = tag[0]
    @pos = tag[1]
  end

  def initialize(char : Char | String,
                 @dic = 0, @idx = 0)
    @key = @val = char.to_s
    @tag, @pos = PosTag::LitBlank
  end

  def swap_val! : self
    @alt.try { |x| @val = x }
    self
  end

  def blank? : Bool
    @key.empty? || @val.blank?
  end

  def inactivate!
    @val = ""
    @pos |= MtlPos.flags(Passive, NoWsBefore, NoWsAfter, CapRelay)
    self
  end

  def apply_cap!(cap : Bool = false) : Bool
    case
    when @pos.cap_relay?    then cap
    when @tag.punctuations? then cap || @pos.cap_after?
    else
      @val = @val.capitalize if cap && !@tag.str_emoji?
      false
    end
  end

  # private def capitalize!
  #   chars = @val.chars
  #   upper = chars.size

  #   @val = String.build(upper) do |io|
  #     i = 0

  #     while i < upper
  #       char = chars.unsafe_fetch(i)
  #       i &+= 1

  #       if char.alphanumeric?
  #         io << char.upcase
  #         break
  #       end

  #       io << char
  #     end

  #     while i < upper
  #       char = chars.unsafe_fetch(i)
  #       i &+= 1
  #       io << char
  #     end
  #   end
  # end

  def to_txt(io : IO) : Nil
    io << @val
  end

  def to_mtl(io : IO) : Nil
    io << '\t' << @val << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @key.size
  end

  def inspect(io : IO = STDOUT, pad = -1) : Nil
    io << " " * pad if pad >= 0
    io << "[#{@val.colorize.light_yellow.bold}] #{@key.colorize.blue} #{@tag.colorize.light_cyan} #{@dic} #{@idx.colorize.dark_gray}"
    io << '\n' if pad >= 0
  end

  def as_advb!(val : String? = nil)
    @val = val if val
    @tag, @pos = PosTag.cast_advb(@key)
    self
  end

  def as_adjt!(val : String? = nil)
    @val = val if val
    @tag, @pos = PosTag.cast_adjt(@key)
    self
  end

  def as_noun!(val : String? = nil)
    @val = val if val
    @tag, @pos = PosTag.cast_noun(@key)
    self
  end

  def as_verb!(val : String? = nil)
    @val = val if val
    @tag, @pos = PosTag.cast_verb(@key)
    self
  end
end
