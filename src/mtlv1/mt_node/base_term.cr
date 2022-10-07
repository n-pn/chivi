require "./base_node"

require "../pos_tag"
require "../vp_dict/vp_term"
require "../mt_core/mt_util"
require "../../_util/text_util"

module CV::MtUtil
  COSTS = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }

  def self.cost(size : Int32, prio : Int8 = 0) : Int32
    COSTS[(size &- 1) &* 4 &+ prio]? || size &* (prio &* 2 &+ 7) &* 2
  end
end

# reopen class VpTerm
class CV::VpTerm
  # auto generated fields
  getter ptag : PosTag { PosTag.init(@tags[0], @key, @vals) }

  getter cost : Int32 { MtUtil.cost(@key.size, @prio) }
end

class CV::MtTerm < CV::BaseNode
  def self.from(term : VpTerm, dic = 0, idx = 0)
    new(term.key, term.vals[0], term.ptag, dic, idx, alt: term.vals[1]?)
  end

  def self.from(char : Char, dic = 0, idx = 0)
    str = char.to_s
    new(str, str, dic: dic, idx: idx)
  end

  getter alt : String? = nil

  def initialize(@key, @val = @key, @tag = PosTag::LitBlank, @dic = 0, @idx = 0, @alt = nil)
  end

  def swap_val!
    if alt = @alt
      @val = alt
    end

    self
  end

  def as_verb!(val = @alt)
    @val = val if val
    @pos = PosTag.map_verbal(@key)
    self
  end

  def as_adjt!(val = @alt)
    @val = val if val
    @pos = PosTag.map_adjtval(@key)
    self
  end

  def as_noun!(val : String | Nil = @alt)
    @val = val if val
    @pos = PosTag.map_nounish(@key)
    self
  end

  def as_advb!(val : String | Nil = @alt)
    @val = val if val
    @pos = PosTag.map_adverb(@key)
    self
  end

  def blank? : Bool
    @key.empty? || @val.blank?
  end

  def empty!(flip = true) : self
    @val = ""
    @tag.pos |= (flip ? MtlPos::NoWsAfter : MtlPos::NoWsBefore)
    self
  end

  def to_int?
    case @tag
    when .ndigits? then @val.to_i64?
    when .nhanzis? then MtUtil.to_integer(@key)
    else                nil
    end
  rescue err
    nil
  end

  def starts_with?(key : String | Char)
    @key.starts_with?(key)
  end

  def ends_with?(key : String | Char)
    @key.ends_with?(key)
  end

  def find_by_key(key : String | Char)
    return self if @key.includes?(key)
  end

  def key_is?(key : String)
    @key == key
  end

  def key_in?(*keys : String)
    keys.includes?(@key)
  end

  def lit_str?
    @key.matches?(/^[a-zA-Z0-9_.-]+$/)
  end

  def each
    yield self
  end

  #########

  def apply_cap!(cap : Bool = false) : Bool
    return cap if @val.blank? || @tag.empty?
    return cap_after?(cap) if @tag.puncts?

    @val = TextUtil.capitalize(@val) if cap && !@tag.str_emoji?
    false
  end

  private def cap_after?(prev = false) : Bool
    @tag.cap_after?
  end

  def space_before?(prev : MtTerm) : Bool
    return false if @val.blank? || prev.tag.space?
    return space_before?(prev.prev?) if prev.val.empty?
    !(prev.tag.no_ws_after? || !@tag.no_ws_before?)
  end

  def space_before?(prev : BaseNode) : Bool
    return false if @val.blank?
    !(prev.tag.no_ws_after? || !@tag.no_ws_before?)
  end

  #######

  def to_txt(io : IO) : Nil
    io << @val
  end

  def to_mtl(io : IO) : Nil
    io << '\t' << @val
    dic = @tag.puncts? || @val == "" ? 0 : @dic
    io << 'ǀ' << dic << 'ǀ' << @idx << 'ǀ' << @key.size
  end

  def inspect(io : IO = STDOUT, pad = -1) : Nil
    io << " " * pad if pad >= 0
    io << "[#{@key}/#{@val}/#{@tag.tag}/#{@dic}/#{@idx}]"
    io << '\n' if pad >= 0
  end
end
