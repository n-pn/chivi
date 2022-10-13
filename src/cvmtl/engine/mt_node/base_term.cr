require "./base_node"

require "../mt_data/mt_term"
require "../mt_core/mt_util"
require "../../../_util/text_util"

class MT::BaseTerm < MT::BaseNode
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
    @tag, @pos = MapTag::LitBlank
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
    @pos = MtlPos.flags(Passive, NoWsBefore)
    self
  end

  def apply_cap!(cap : Bool = false) : Bool
    case
    when @pos.passive?      then cap
    when @tag.punctuations? then cap || @pos.cap_after?
    else
      @val = CV::TextUtil.capitalize(@val) if cap
      false
    end
  end

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
    @tag, @pos = MapTag.cast_advb(@key)
    self
  end

  def as_adjt!(val : String? = nil)
    @val = val if val
    @tag, @pos = MapTag.cast_adjt(@key)
    self
  end

  def as_noun!(val : String? = nil)
    @val = val if val
    @tag, @pos = MapTag.cast_noun(@key)
    self
  end

  def as_verb!(val : String? = nil)
    @val = val if val
    @tag, @pos = MapTag.cast_verb(@key)
    self
  end
end
