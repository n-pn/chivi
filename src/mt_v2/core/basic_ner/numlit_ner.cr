require "../../../_util/char_util"
require "../pos_tag"

module M2::NumlitNER
  extend self

  PROX_WORDS = {
    '来' => "chừng ",
    '余' => "trên ",
    '多' => "hơn ",
  }

  def detect(input : Array(Char), index : Int32 = 0, prev_val = "")
    int_arr = [] of Int64

    has_unit = false
    is_appro = !prev_val.empty?

    upper = input.size
    while index < upper
      char = input.unsafe_fetch(index)

      if appro = PROX_WORDS[char]?
        prev_val += appro
        is_appro = true
      else
        break unless int = CharUtil::HANNUM_VALUE[char]?
        has_unit ||= int > 9
        int_arr << int.to_i64
      end

      index &+= 1
    end

    # FIXME: handle 两 as quantifier

    if has_unit
      val = han_to_vi_with_unit(int_arr, prev_val)
      tag = is_appro ? PosTag::Mprox : PosTag::Mlit
    else
      val = han_to_vi_no_unit(int_arr)
      tag = PosTag::Mlit
    end

    {index, tag, prev_val + val}
  end

  NUM_VAL = {"không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"}

  private def han_to_vi_no_unit(int_arr : Array(Int64))
    String.build do |io|
      int_arr.each_with_index(0) do |int, i|
        io << ' ' if i > 0
        io << NUM_VAL[int]?
      end
    end
  end

  private def han_to_vi_with_unit(input : Array(Int64), prev_val = "")
    output = map_hanzi_list_to_tran_unit_list(input, prev_val)
    # puts input, output
    output = reduce_tran_unit_list_unit(output)
    # puts output

    String.build do |io|
      prev = output.unsafe_fetch(0)
      prev.to_s(io)

      1.upto(output.size - 1) do |i|
        io << ' '

        item = output.unsafe_fetch(i)
        item.to_s(io, prev.unit)
        prev = item
      end
    end
  end

  private def map_hanzi_list_to_tran_unit_list(input : Array(Int64), prev_val = "")
    output = [] of Unit

    input.each do |int|
      next if int == 0

      if int < 10
        output << Unit.new(NUM_VAL[int], 1)
        next
      end

      if last = output.last?
        pending = Unit.new("", int) if last.unit > int

        output.reverse_each do |item|
          break if item.unit > int
          item.unit &*= int
        end

        output << pending if pending
      elsif prev_val.empty?
        output << Unit.new("một", int)
      else
        output << Unit.new("", int)
      end
    end

    output
  end

  private def reduce_tran_unit_list_unit(output : Array(Unit))
    i = output.size - 1
    while i >= 0
      item = output.unsafe_fetch(i)
      i &-= 1

      case item.unit
      when .< 1000          then next
      when .< 1_000_000     then unit = 1000_i64
      when .< 1_000_000_000 then unit = 1_000_000_i64
      else                       unit = 1_000_000_000_i64
      end

      if item.unit != unit
        output.insert(i &+ 2, Unit.new("", unit))
        item.unit //= unit
      end

      ceil = unit * unit
      j = i

      while j >= 0
        item = output.unsafe_fetch(j)
        break unless item.unit < ceil

        item.unit //= unit
        item.unit = 1 if item.unit == output.unsafe_fetch(j &+ 1).unit

        j &-= 1
      end
    end

    output
  end

  class Unit
    getter tran : String
    property unit : Int64 = 0

    def initialize(@tran, @unit)
    end

    def to_s(io : IO = STDOUT, prev_unit = 0_i64)
      if prev_unit > @unit * 10
        io << "lẻ "
      end

      if prev_unit == 10 && @tran == "năm"
        io << "lăm"
      elsif @tran == "một" && @unit == 10
        io << "mười"
        return
      else
        io << @tran
      end

      return if unit == 1
      io << " " unless @tran.blank?
      unit_to_s(io)
    end

    def unit_to_s(io : IO)
      case unit
      when            10 then io << "mươi"
      when           100 then io << "trăm"
      when          1000 then io << "nghìn"
      when     1_000_000 then io << "triệu"
      when 1_000_000_000 then io << "tỉ"
      end
    end

    def inspect(io : IO)
      io << {@tran, @unit}
    end
  end
end
