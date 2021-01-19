require "../../_utils/text_utils"
require "../vp_dict/vp_entry"

class CV::CvEntry
  property key : String
  property val : String
  property dic : Int32

  getter etc : String

  getter is_noun : Bool { @etc.includes?('🅽') }
  getter is_verb : Bool { @etc.includes?('🆅') }
  getter is_pro : Bool { @etc.includes?('🅿') }
  getter is_adj : Bool { @etc.includes?('🅰') }

  NUM_RE = /[\d零〇一二两三四五六七八九十百千万亿]/
  getter is_num : Bool { NUM_RE === @key }

  INT_RE = /^\d+$/
  getter is_int : Bool { INT_RE === @key }

  def initialize(entry : VpEntry)
    @key = entry.key
    @val = entry.vals.first
    @dic = entry.dtype
    @etc = entry.attrs
  end

  def initialize(@key, @val = @key, @dic = 0, @etc = "")
  end

  def capitalize!(cap_mode : Int32 = 1) : Nil
    @val = cap_mode > 1 ? TextUtils.titleize(@val) : TextUtils.capitalize(@val)
  end

  def cap_mode(prev_mode : Int32 = 0) : Int32
    case @val[-1]?
    when '“', '‘', '[', '{',
         ':', '!', '?', '.'
      prev_mode > 1 ? 2 : 1
    when '⟨'
      2
    when '⟩'
      0
    else
      prev_mode
    end
  end

  def space_before?(prev : CvEntry)
    return false if @val.blank? || prev.val.blank?

    # handle .jpg case
    return false if @dic == 1 && @key =~ /^\.\w/

    case @val[0]?
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ';', '!', '?',
         '%', ':'
      return false
    when '·'
      return true
    when '~', '-', '—'
      return @dic > 1 || prev.dic > 1
    when '…'
      return prev.val[-1]? == '.'
    end

    case prev.val[-1]?
    when '“', '‘', '⟨', '(', '[', '{'
      return false
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ';', '!', '?',
         '…', '·'
      return true
    when ':'
      return !is_int
    when '~', '-', '—'
      @dic > 1 || prev.dic > 1
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
    @dic = 0
  end
end
