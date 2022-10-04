require "./mt_node"

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

class CV::MtTerm < CV::MtNode
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

  def blank?
    @key.empty? || @val.blank?
  end

  def to_int?
    case @tag
    when .ndigit? then @val.to_i64?
    when .nhanzi? then MtUtil.to_integer(@key)
    else               nil
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

  def modifier?
    @tag.modi? || (@tag.adjt? && @key.size < 3)
  end

  def lit_str?
    @key.matches?(/^[a-zA-Z0-9_.-]+$/)
  end

  def each
    yield self
  end

  #########

  def apply_cap!(cap : Bool = false) : Bool
    return cap if @val.blank? || @tag.none?
    return cap_after?(cap) if @tag.puncts?

    @val = TextUtil.capitalize(@val) if cap && !@tag.fixstr?
    false
  end

  private def cap_after?(prev = false) : Bool
    case @tag
    when .exmark?, .qsmark?, .pstop?, .colon?,
         .middot?, .titleop?, .brackop?
      true
    when .pdeci?
      @prev.try { |x| x.ndigit? || x.litstr? } || prev
    else
      prev
    end
  end

  def space_before?(prev : MtTerm) : Bool
    return false if @val.blank? || prev.tag.space?
    return space_before?(prev.prev?) if prev.val.empty?
    !(prev.tag.no_ws_after? || !@tag.no_ws_before?)
  end

  def space_before?(prev : MtNode) : Bool
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
