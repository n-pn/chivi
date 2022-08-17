require "./mt_node"
require "../vp_dict/vp_term"
require "../mt_core/mt_util"
require "../../_util/text_util"

class CV::MtTerm < CV::MtNode
  ###########
  #

  def initialize(@key, @val = @key, @tag = PosTag::None, @dic = 0, @idx = 0)
  end

  def initialize(term : VpTerm, @dic : Int32 = 0, @idx = 0)
    @key = term.key
    @val = term.vals.first
    @tag = term.ptag
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
