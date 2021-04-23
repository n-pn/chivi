require "../../utils/text_utils"
require "../vdict/vterm"

class CV::Cword
  property key : String
  property val : String

  property dic : Int32
  property cat : Int32 = 0

  # TODO: add more words
  NUM_RE = /^[\p{N}零〇一二两三四五六七八九十百千万亿]+$/
  getter is_num : Bool { NUM_RE === @key }

  INT_RE = /^\d+$/
  getter is_int : Bool { INT_RE === @key }

  def initialize(term : Vterm)
    @key = term.key
    @val = term.vals.first
    @cat = term.attr
    @dic = term.dtype
  end

  def initialize(@key, @val = @key, @dic = 0, @cat = 0)
  end

  def fix(@val : String, @dic = 9, @cat = @cat) : Nil
  end

  def match_key?(key : String)
    @key == key
  end

  @[AlwaysInline]
  def word?
    @dic > 0
  end

  @[AlwaysInline]
  def noun?
    @cat & 1 != 0
  end

  @[AlwaysInline]
  def verb?
    @cat & 2 != 0
  end

  @[AlwaysInline]
  def adje?
    @cat & 4 != 0
  end

  def capitalize!(cap_mode : Int32 = 1) : Nil
    @val = cap_mode > 1 ? TextUtils.titleize(@val) : TextUtils.capitalize(@val)
  end

  def cap_mode(prev_mode : Int32 = 0) : Int32
    case @val[-1]?
    when '“', '‘', '[', '{',
         ':', '!', '?', '.'
      prev_mode > 1 ? 2 : 1
    when ',', '}', ']'
      prev_mode == 2 ? 2 : 0
    when '⟩'
      0
    when '⟨'
      2
    else
      prev_mode
    end
  end

  def space_before?(prev : Cword)
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

  def combine!(other : Cword) : Nil
    @key = "#{other.key}#{@key}"
    @val = "#{other.val}#{@val}"
  end

  def to_i?
    @key.to_i?
  end

  def clear!
    @key = ""
    @val = ""
    @dic = 0
  end

  def pronoun?
    case @key
    when "我", "我们",
         "你", "你们",
         "他", "他们",
         "她", "她们",
         "朕"
      true
    else
      false
    end
  end

  def merge!(key : String, val : String, cat : Int32 = 0, dic = @dic)
    @key = "#{@key}#{key}"
    @val = "#{@val} #{val}"
    @cat |= cat
    @dic = dic
  end
end
