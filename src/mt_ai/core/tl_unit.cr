require "log"
require "colorize"

module MT::TlUnit
  extend self

  HAN_TO_INT = {
    '零' => 0, '两' => 2,
    '〇' => 0, '一' => 1,
    '二' => 2, '三' => 3,
    '四' => 4, '五' => 5,
    '六' => 6, '七' => 7,
    '八' => 8, '九' => 9,
    '十' => -1, '百' => -2,
    '千' => -3, '万' => -4,
    '亿' => -6, '兆' => -9,
  }

  EXTRA_STR = {
    '来' => "chừng",
    '余' => "trên",
    '多' => "hơn",
    '第' => "thứ",
    '几' => "mấy",
  }

  class Digit
    property char : Char
    property unit : Int32

    def initialize(@char, @unit = 0)
    end

    @[AlwaysInline]
    def pure_digit?
      pure_digit?(@char)
    end

    @[AlwaysInline]
    private def pure_digit?(char : Char)
      '0' <= char <= '9'
    end

    @[AlwaysInline]
    private def pure_digit?(vstr : String)
      pure_digit?(vstr[0])
    end

    LITS = {"không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"}

    def to_digit(io : IO, prev_unit = 0)
      zeros = @char == ' ' ? prev_unit : (prev_unit - @unit - 1)
      zeros.times { io << '0' }

      case
      when @char == ' ' # do nothing
      when '0' <= @char <= '9' then io << @char
      else                          io << @char - 0xfee0
      end
    end

    def render(io : IO, use_raw : Bool = self.pure_digit?(@char)) : Nil
      io << (use_raw ? @char : LITS[@char - '０'])
    end

    def render(io : IO, prev_unit = 0, use_raw = false) : Nil
      io << "lẻ " if prev_unit - @unit > 1

      case
      when prev_unit == 1 && @char == '１'
        io << "mốt"
      when prev_unit == 1 && @char == '５'
        io << "năm"
      when @unit == 1 && (@char == '１' || use_raw)
        if use_raw
          io << @char << '0'
        else
          io << "mười"
        end

        return
      when @unit == 1 && use_raw
        return
      when @char != ' '
        render(io, use_raw: use_raw)
      end

      return if @unit == 0
      io << ' ' unless @char == ' '

      case @unit
      when 1 then io << "mươi"
      when 2 then io << "trăm"
      when 3 then io << "nghìn"
      when 6 then io << "triệu"
      when 9 then io << "tỉ"
      end
    end

    def inspect(io : IO)
      io << '{' << @char << ':' << @unit << '}'
    end
  end

  def translate(zstr : String, digit_only : Bool = false)
    digits = [] of Digit

    no_unit = true
    pre_str = ""
    suf_str = ""

    zstr.each_char do |char|
      if char.in?('0'..'9')
        digits << Digit.new(char)
      elsif char.in?('０'..'９')
        digits << Digit.new(char - 0xfee0) # to half width
      elsif extra = EXTRA_STR[char]?
        pre_str = pre_str.empty? ? extra : "#{pre_str} #{extra}"
      elsif !(int = HAN_TO_INT[char]?)
        Log.error { "#{char} not match any known type" }
        pre_str = pre_str.empty? ? char.to_s : "#{pre_str} #{char}"
      elsif int >= 0
        digits << Digit.new('０' + int) # convert to full width form
      else
        no_unit = false
        unit = -int

        if last = digits.last?
          digit = Digit.new(' ', unit) if last.unit > unit

          digits.reverse_each do |dig|
            break if dig.unit > unit
            dig.unit &+= unit
          end

          digits << digit if digit
        else
          vstr = pre_str.empty? ? '１' : ' '
          digits << Digit.new(vstr, unit)
        end
      end
    end

    return pre_str if digits.empty?

    if digit_only
      render_pure_digit(digits, pre_str)
    elsif no_unit
      render_no_unit(digits, pre_str)
    else
      render_unit(digits, pre_str)
    end
  end

  private def render_no_unit(digits : Array(Digit), pre_str : String)
    String.build do |io|
      io << pre_str << ' ' unless pre_str.empty?
      was_digit = false

      digits.each_with_index do |digit, index|
        is_digit = digit.pure_digit?
        io << ' ' if index > 0 && !(was_digit && is_digit)

        digit.render(io, is_digit)
        was_digit = is_digit
      end
    end
  end

  private def render_pure_digit(digits : Array(Digit), pre_str : String)
    digits = fix_digits_unit!(digits)
    # pp digits.colorize.blue

    String.build do |io|
      io << pre_str
      prev_unit = 0

      digits.each do |digit|
        digit.to_digit(io, prev_unit)
        prev_unit = digit.unit
      end

      prev_unit.times { io << '0' }
    end
  end

  private def render_unit(digits : Array(Digit), pre_str : String)
    digits = fix_digits_unit!(digits)
    # pp digits

    String.build do |io|
      io << pre_str

      prev = digits.unsafe_fetch(0)
      was_digit = prev.pure_digit?
      prev_unit = prev.unit
      prev.render(io, prev_unit: 0, use_raw: was_digit)

      1.upto(digits.size &- 1) do |i|
        digit = digits.unsafe_fetch(i)
        is_digit = digit.pure_digit?

        io << ' ' unless is_digit && was_digit
        digit.render(io, prev_unit, use_raw: is_digit)

        was_digit = is_digit

        if digit.char == ' '
          prev_unit += digit.unit
        else
          prev_unit = digit.unit
        end
      end
    end
  end

  private def fix_digits_unit!(digits : Array(Digit))
    i = digits.size &- 1

    while i >= 0
      digit1 = digits.unsafe_fetch(i)
      i &-= 1

      case digit1.unit
      when 1
        next unless digit1.pure_digit?
        next unless digit2 = digits[i + 2]?
        next unless digit2.pure_digit?
        digit1.unit = 0
        next
      when .< 3 then next
      when .< 6 then unit = 3
      when .< 9 then unit = 6
      else           unit = 9
      end

      if digit1.unit != unit
        digits.insert(i &+ 2, Digit.new(' ', unit))
        digit1.unit -= unit
      end

      ceil = unit &+ unit

      j = i

      while j >= 0
        digit2 = digits.unsafe_fetch(j)
        break unless digit2.unit < ceil

        digit2.unit -= unit
        digit2.unit = 0 if digit2.unit == digits.unsafe_fetch(j &+ 1).unit

        j &-= 1
      end
    end

    digits
  end
end
