require "../../shared/text_utils"

class CV::CvEntry
  property key : String
  property val : String

  property dic : Int32
  property etc : String

  def initialize(@key : String, @val : String, @dic : Int32 = 0, @etc = "")
  end

  def capitalize!(cap_mode : Int32 = 1) : Nil
    @val = cap_mode > 1 ? TextUtils.titleize(@val) : TextUtils.capitalize(@val)
  end

  def combine!(other : self) : Nil
    @key = "#{other.key}#{@key}"
    @val = "#{other.val}#{@val}"
  end

  def number?
    return false if @dic < 1
    return @key =~ /^\d+(\.\d+)?$/ if @dic == 1
    @key =~ /^[零〇一二两三四五六七八九十百千]+$/
  end

  def to_i? : Int32?
    return if @dic != 1
    @key.to_i?
  end

  def to_f? : Float32?
    return if @dic != 1
    @key.to_f?
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

  def space_before?(prev : self)
    return false if @val.blank? || prev.val.blank?

    # handle .jpg case
    return false if @dic == 1 && @key[0]? == '.'

    case @val[0]?
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ':', ';', '!', '?',
         '%', '~'
      return false
    when '·'
      return true
    when '…'
      case prev.val[-1]?
      when '.', ','
        return true
      else
        return false
      end
    end

    case prev.val[-1]?
    when '“', '‘', '⟨', '(', '[', '{'
      return false
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ':', ';', '!', '?',
         '…', '~', '—', '·'
      return true
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

  def fix_unit!(prev : CvEntry?, val : String) : Void
    return unless prev && prev.number?
    @dic = 9
    @val = val
  end

  def clear!
    @dic = 0
    @key = ""
    @val = ""
  end
end
