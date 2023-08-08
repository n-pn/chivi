require "log"

module AI::QtNumber
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
    '来' => "chừng ",
    '余' => "trên ",
    '多' => "hơn ",
    '第' => "thứ ",
  }

  class Digit
    property char : String | Char
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

    def render(io : IO, use_raw : Bool = self.pure_digit?(@char)) : Nil
      return io << @char if use_raw

      case vstr = @char
      in Char
        io << LITS[vstr - '０']
      in String
        spaced = false
        vstr.each_char do |char|
          io << ' ' unless spaced
          io << LITS[char - '０']
          spaced = true
        end
      end
    end

    def render(io : IO, prev_unit = 0, use_raw = false) : Nil
      io << "lẻ " if prev_unit - @unit > 1

      case
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

  def translate(zstr : String)
    digits = [] of Digit

    no_unit = true
    pre_str = ""

    zstr.each_char do |char|
      if char.in?('0'..'9')
        digits << Digit.new(char)
      elsif char.in?('０'..'９')
        digits << Digit.new(char - 0xfee0) # to half width
      elsif extra = EXTRA_STR[char]?
        pre_str = extra + pre_str
      elsif !(int = HAN_TO_INT[char]?)
        Log.error { "#{char} not match any known type" }
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

    if no_unit
      render_no_unit(digits, pre_str)
    else
      render_unit(digits, pre_str)
    end
  end

  private def render_no_unit(digits : Array(Digit), pre_str : String)
    String.build do |io|
      io << pre_str
      was_digit = false

      digits.each_with_index do |digit, index|
        is_digit = digit.pure_digit?
        io << ' ' if index > 0 && !(was_digit && is_digit)

        digit.render(io, is_digit)
        was_digit = is_digit
      end
    end
  end

  private def render_unit(digits : Array(Digit), pre_str : String)
    i = digits.size &- 1

    # pp digits

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

  # test = {
  #   "六七",
  #   "123",
  #   "12七",
  #   "12七8",
  #   "六12七8",

  #   "2百万",
  #   "25百万",
  #   "1万",
  #   "1万6千",
  #   "2万6千",
  #   "1万6百",
  #   "六七万",
  #   "六十七万",
  #   "七十万",
  #   "十万",
  #   "十千",
  #   "六万七千",
  #   "十七",
  # }
  # test.each do |item|
  #   puts "#{item} => [#{translate(item)}]"
  # end
end