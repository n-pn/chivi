require "./mt_node"
require "./pos_tag"

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
  getter ptag : PosTag { PosTag.parse(@tags[0], @key, @vals[0]) }
  getter cost : Int32 { MtUtil.cost(@key.size, @prio) }
end

class CV::MtTerm < CV::MtNode
  ###########

  def initialize(@key, @val = @key, @tag = PosTag::None, @dic = 0, @idx = 0)
  end

  def initialize(term : VpTerm, @dic : Int32 = 0, @idx = 0)
    @key = term.key
    @val = term.vals.first
    @tag = term.ptag

    case attr = @tag.attr
    when PosTag::PunctAttr
      @val = "," if attr.cenum?
    end
  end

  def initialize(char : Char, @idx = 0)
    @key = @val = char.to_s
    @tag =
      case char
      when ' ' then PosTag::Punct
      when '_' then PosTag::Litstr
      else
        char.alphanumeric? ? PosTag::Litstr : PosTag::None
      end
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
    self.tag.puncts?(&.cap_after?) || prev
  end

  def space_before?(prev : Nil) : Bool
    false
  end

  def space_before?(prev : MtList) : Bool
    return false if @val.blank?
    return !prev.popens? unless @tag.puncts?

    case @tag
    when .colon?, .pdeci?, .pstops?, .comma?, .penum?,
         .pdeci?, .ellip?, .tilde?, .perct?, .squanti?
      false
    else
      true
    end
  end

  def space_before?(prev : MtTerm) : Bool
    return false if @val.blank? || prev.val == " "

    return space_before?(prev.prev?) if prev.val.empty?

    case
    when prev.popens?, @tag.ndigit?
      return false
    else
      return true unless @tag.puncts?
    end

    self.tag.puncts?(&.no_wspace?.!) || true
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
