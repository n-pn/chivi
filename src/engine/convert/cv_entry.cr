require "../../_utils/text_utils"
require "../vp_dict/vp_term"

class CV::CvEntry
  property key : String
  property val : String

  property dic : Int8
  getter cat : Int8 = 0_i8

  # TODO: add more words
  NUM_RE = /^[\p{N}零〇一二两三四五六七八九十百千万亿]+$/
  getter is_num : Bool { NUM_RE === @key }

  INT_RE = /^\d+$/
  getter is_int : Bool { INT_RE === @key }

  def initialize(term : VpTerm)
    @dic = term.dtype
    @key = term.key
    @val = term.vals.first
    @cat = term.attr
  end

  def initialize(@key, @val = @key, @dic = 0_i8, @cat = 0_i8)
  end

  def fix(@val : String, @dic = 9_i8) : Nil
  end

  def match_key?(key : String)
    @key == key
  end

  @[AlwaysInline]
  def word?
    @dic > 0_i8
  end

  @[AlwaysInline]
  def noun?
    @cat & 1_i8 != 0_i8
  end

  @[AlwaysInline]
  def verb?
    @cat & 2_i8 != 0_i8
  end

  @[AlwaysInline]
  def adjv?
    @cat & 4_i8 != 0_i8
  end

  def capitalize!(cap_mode : Int8 = 1) : Nil
    @val = cap_mode > 1 ? TextUtils.titleize(@val) : TextUtils.capitalize(@val)
  end

  def cap_mode(prev_mode : Int8 = 0) : Int8
    case @val[-1]?
    when '“', '‘', '[', '{',
         ':', '!', '?', '.'
      prev_mode > 1_i8 ? 2_i8 : 1_i8
    when ',', '⟩', '}', ']'
      0_i8
    when '⟨'
      2_i8
    else
      prev_mode
    end
  end

  def space_before?(prev : CvEntry)
    return false if @val.blank? || prev.val.blank?

    # handle .jpg case
    return false if @dic == 1 && @key =~ /^\.\w/

    prev_val = prev.val[-1]?

    case @val[0]?
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ';', '!',
         '%', '~', '?'
      return prev_val == ':'
    when '…'
      return prev_val == ':' || prev_val == '.'
    when ':'
      return false
    when '-', '—'
      return prev.dic > 1
    when '·'
      return true
    end

    case prev_val
    when '“', '‘', '⟨', '(', '[', '{'
      return false
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ';', '!', '?', ':',
         '…', '·'
      return true
    when '~', '-', '—'
      @dic > 1
    end

    @dic > 0 || prev.dic > 0
  end

  def special_mid_char?
    case @key[0]?
    when ':', '/', '.', '-', '+', '?', '%', '#', '&'
      true
    else
      false
    end
  end

  def match_rule_对?
    if @dic == 0
      @val[0]? == '“'
    else
      @key != "的"
    end
  end

  def letter?
    @dic > 0
  end

  def special_end_char?
    case @key[0]?
    when '-', '+', '?', '%', '°'
      true
    else
      false
    end
  end

  def combine!(other : CvEntry) : Nil
    @key = "#{other.key}#{@key}"
    @val = "#{other.val}#{@val}"
  end

  def to_i?
    @key.to_i?
  end

  def clear!
    @key = ""
    @val = ""
    @dic = 0_i8
  end
end
