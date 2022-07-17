require "./mt_node"
require "../mt_core/mt_util"
require "../../_util/text_util"

class CV::MtTerm < CV::MtNode
  def self.naive_ner(input : Array(Char), index = 0, offset = 0)
    key_io = String::Builder.new
    chars = digits = puncts = spaces = caps = letters = 0

    input[index..].each do |char|
      case char
      when .numbers?
        digits += 1
      when .letters?
        letters += 1
        caps += 1 if char.uppercase?
      when '_'
        letters += 1
      when ' '
        spaces += 1
      when ':', '/', '.', '?', '@', '=', '%', '+', '-', '~'
        break unless chars > 0
        puncts += 1
      else
        break
      end

      chars += 1
      key_io << char
    end

    return if chars == 0

    key = key_io.to_s
    case
    when letters == chars then tag = Postag::Veno
    when letters > 0      then tag = litstr_tag(key, spaces, caps)
    when puncts == 0      then tag = PosTag::Ndigit
    else                       tag = number_tag(key)
    end

    new(key, tag: tag, idx: index + offset, dic: 0)
  end

  def self.litstr_tag(key : String, spaces = 0, caps = 0)
    case
    when spaces > 0
      Postag::Litstr
    when caps > 0
      PosTag::Nother
    when key =~ /https?\:|www\./
      PosTag::Urlstr
    else
      Postag::Litstr
    end
  end

  def self.number_tag(key : String)
    case key
    when /^[0-9０-９]+:[0-9０-９]+(:[0-9０-９]+)*$/,
         /^[0-9０-９]+\/[0-9０-９]+\/[0-9０-９]+$/
      PosTag::Ntime
    when  /^[0-9０-９]+[~\-.]/[0-9０-９]+$/
      PosTag::Number
    else
      PosTag::Litstr
    end
  end

  ###########
  #

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
    return space_before?(prev.prev?) if prev.val.empty?

    case
    when @val.blank?, prev.popens?,
         @tag.ndigit? && (prev.plsgn? || prev.mnsgn?)
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
