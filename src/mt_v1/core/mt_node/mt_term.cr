require "./mt_base"

require "../pos_tag"
require "../mt_core/mt_util"
require "../../../_util/text_util"

class M1::ZvDefn < M1::MtNode
  def self.cost(size : Int32, prio : Int32 = 0)
    return 0 if prio < 1

    COSTS[(size &- 1) &* 4 &+ prio]? || size &* (prio &* 2 &+ 7) &* 2
  end

  COSTS = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }

  ###########

  getter cost : Int32 = 0

  def initialize(@key, @val = @key, @tag = PosTag::Unkn, @dic = 0, @idx = 0, prio = 2)
    @cost = self.class.cost(key.size, prio)
  end

  def initialize(@key, @val, @dic, ptag : String, prio : Int32)
    @tag = PosTag.parse(ptag, key)
    @cost = self.class.cost(key.size, prio)
  end

  def initialize(char : Char, @idx = 0)
    @key = char.to_s
    @val = CharUtil.normalize(char).to_s

    @tag =
      case char
      when ' ' then PosTag::Punct
      when '_' then PosTag::Litstr
      else
        char.alphanumeric? ? PosTag::Litstr : PosTag::None
      end
  end

  def clone!(idx : Int32 = @idx) : self
    ZvDefn.new(
      key: @key, val: @val,
      tag: @tag, dic: @dic,
      idx: idx
    )
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

  def each(&)
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

  def space_before?(prev : ZvDefn) : Bool
    return false if @val.blank? || prev.val == " "
    return space_before?(prev.prev?) if prev.val.empty?

    case
    when prev.popens?, @tag.ndigit? && (prev.plsgn? || prev.mnsgn?)
      return false
    else
      return true unless @tag.puncts?
    end

    case @tag
    when .middot?
      true
    when .plsgn?, .mnsgn?
      !prev.tag.ndigit?
    when .colon?, .pdeci?, .pstops?, .comma?, .penum?,
         .pdeci?, .ellip?, .tilde?, .perct?, .squanti?
      false
    else
      !prev.popens?
    end
  end

  def space_before?(prev : MtNode) : Bool
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
