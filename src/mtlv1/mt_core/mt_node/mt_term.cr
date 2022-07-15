require "./mt_node"
require "../mt_util"
require "../../../_util/text_util"

class CV::MtTerm < CV::MtNode
  def initialize(@key, @val = @key, @tag = PosTag::None, @dic = 0, @idx = 0)
  end

  def initialize(term : VpTerm, @dic : Int32 = 0, @idx = 0)
    @key = term.key
    @val = term.val.first
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

  def set!(@val : String) : self
    self
  end

  def set!(@tag : PosTag) : self
    self
  end

  def set!(@val : String, @tag : PosTag) : self
    self
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

  def find?(key : String | Char)
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

  #########

  def apply_cap!(cap : Bool = false) : Bool
    return cap if @val.blank? || @tag.none
    return cap_after_punct?(cap) if @tag.puncts?

    @val = TextUtil.capitalize(@val) if cap && !@tag.fixstr?
    false
  end

  private def cap_after_punct?(prev = false) : Bool
    case @tag
    when .exmark?, .qsmark?, .pstop?, .colon?,
         .middot?, .titleop?, .quoteop?
      true
    when .pdeci?
      @prev.try { |x| x.ndigit? || x.litstr? } || prev
    else
      prev
    end
  end

  #######

  def to_txt(io : IO) : Nil
    io << @val
  end

  def to_mtl(io : IO) : Nil
    io << "\t" << @val

    # skip rendering if node is empty space
    return if @key == "" && @val == " "

    dic = @tag.puncts? || @val == "" ? 0 : @dic
    io << 'ǀ' << dic << 'ǀ' << @idx << 'ǀ' << @key.size
  end

  def inspect(io : IO = STDOUT, pad = -1) : Nil
    return if @key == "" && @val == " "

    io << " " * pad if pad >= 0
    io << "[#{@key}/#{@val}/#{@tag.tag}/#{@dic}/#{@idx}]"
    io << "\n" if pad >= 0
  end
end
