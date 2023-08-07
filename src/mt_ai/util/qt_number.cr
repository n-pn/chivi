# module AI::QtNumber
#   extend self

#   class Unit
#     property vstr : String
#     property unit : Int32 = 0

#     def initialize(@vstr : String, @unit = 0)
#     end

#     def is_digit?
#       return false unless fchar = @vstr[0]?
#       '0' <= fchar <= '9'
#     end

#     def to_s(io : IO, prev_unit = 0) : Nil
#       # pp self

#       io << "lẻ " if prev_unit > @unit &+ 1

#       if prev_unit == 1 && @vstr == "năm"
#         @vstr = "lăm"
#       elsif @unit == 1 && @vstr.in?("1", "một")
#         @vstr = @vstr == "1" ? "10" : "mười"
#         @unit = 0
#       end

#       io << @vstr
#       return if @unit == 0

#       io << ' ' unless @vstr.blank?

#       case @unit
#       when 1 then io << "mươi"
#       when 2 then io << "trăm"
#       when 3 then io << "nghìn"
#       when 6 then io << "triệu"
#       when 9 then io << "tỉ"
#       end
#     end

#     def inspect(io : IO)
#       io << {@vstr, @unit}
#     end
#   end

#   HAN_TO_INT = {
#     '零' => 0, '两' => 2,
#     '〇' => 0, '一' => 1,
#     '二' => 2, '三' => 3,
#     '四' => 4, '五' => 5,
#     '六' => 6, '七' => 7,
#     '八' => 8, '九' => 9,
#     '十' => -1, '百' => -2,
#     '千' => -3, '万' => -4,
#     '亿' => -6, '兆' => -9,
#   }

#   TRAN_LITS = {"không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"}

#   TRAN_PROX = {
#     '来' => "chừng ",
#     '余' => "trên ",
#     '多' => "hơn ",
#   }

#   def translate(input : String)
#     digs = [] of Unit
#     prox = ""

#     has_unit = false

#     input.each_char do |char|
#       if tran = TRAN_PROX[char]?
#         prox = tran
#       elsif char.in?('0'..'9')
#         if (last = digs.last?) && last.unit == 0 && last.is_digit?
#           last.vstr += char
#         else
#           digs << Unit.new(char.to_s, 0)
#         end
#       elsif int = HAN_TO_INT[char]?
#         if int >= 0
#           digs << Unit.new(TRAN_LITS[int], 0)
#         else
#           int = -int
#           has_unit = true

#           if last = digs.last?
#             curr = Unit.new("", int) if last.unit > int

#             digs.reverse_each do |item|
#               break if item.unit > int
#               item.unit &+= int
#             end

#             digs << curr if curr
#           else
#             vstr = prox.empty? ? "một" : ""
#             digs << Unit.new(vstr, int)
#           end
#         end
#       else
#         puts "#{char} not match any known type"
#       end
#     end

#     if has_unit
#       translate_with_unit(digs, prox)
#     else
#       translate_no_unit(digs, prox)
#     end
#   end

#   private def translate_no_unit(digs : Array(Unit), prox : String = "")
#     String.build do |io|
#       io << prox
#       digs.join(io, ' ') { |unit, _| io << unit.vstr }
#     end
#   end

#   private def translate_with_unit(digs : Array(Unit), prox : String = "")
#     i = digs.size &- 1

#     while i >= 0
#       dig1 = digs.unsafe_fetch(i)
#       i &-= 1

#       case dig1.unit
#       when .< 3 then next
#       when .< 6 then unit = 3
#       when .< 9 then unit = 6
#       else           unit = 9
#       end

#       ceil = unit &+ unit
#       j = i

#       while j >= 0
#         dig2 = digs.unsafe_fetch(j)
#         break unless dig2.unit < ceil

#         dig2.unit -= unit
#         dig2.unit = 0 if dig2.unit == digs.unsafe_fetch(j &+ 1).unit

#         j &-= 1
#       end

#       next if dig1.unit == unit

#       if dig1.is_digit? && (succ = digs[i &+ 2]?) && succ.is_digit?

#       digs.insert(i &+ 2, Unit.new("", unit))
#       dig1.unit -= unit
#     end

#     String.build do |io|
#       io << prox

#       prev = digs.unsafe_fetch(0)
#       prev.to_s(io)

#       1.upto(digs.size &- 1) do |i|
#         io << ' ' # unless (prev.is_digit? && item.is_digit?)
#         item = digs.unsafe_fetch(i)
#         item.to_s(io, prev.unit)
#         prev = item
#       end
#     end
#   end

#   test = {
#     "2百万",
#     "25百万",
#     "1万",
#     "1万6千",
#     "1万6百",
#     "六七",
#     "六七万",
#     "六万七千",
#     "十七",
#   }
#   test.each do |item|
#     puts "#{item} => #{translate(item)}"
#   end
# end
