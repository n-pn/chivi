# module AI::QtNumber
#   extend self

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

#   private def to_vstr(char : Char)
#     char > '9' ? TRAN_LITS[char - '０'] : char
#   rescue
#     char
#   end

#   def translate(input : String)
#     digs = [] of Char
#     prox = ""

#     has_unit = false

#     base_unit = 0

#     input.chars.reverse_each do |char|
#       base_unit += 1

#       case
#       when char.in?('0'..'9')
#         digs << char
#       when char == '第'
#         prox = "thứ "
#       when tran = TRAN_PROX[char]?
#         prox = tran + prox
#         base_unit -= 1
#       when !(int = HAN_TO_INT[char]?)
#         puts "#{char} not match any known type"
#       when int >= 0
#         digs << '０' + int
#       else
#         bump_unit = -int
#         if bump_unit > base_unit
#           (bump_unit - base_unit).times { digs << ' ' }
#           base_unit = bump_unit
#         end

#         has_unit = true
#       end
#     end

#     digs.reverse!

#     if has_unit
#       translate_with_unit(digs, prox)
#     else
#       translate_no_unit(digs, prox)
#     end
#   end

#   private def translate_no_unit(digs : Array(Char), prox : String = "")
#     String.build do |io|
#       io << prox
#       digs.join(io, ' ') { |char, _| io << to_vstr(char) }
#     end
#   end

#   private def translate_with_unit(digs : Array(Char), prox : String = "")
#     rem = digs.size % 3
#     (3 - rem).times { digs.unshift(' ') } if rem != 0

#     pp digs

#     seg_count = digs.size // 3

#     String.build do |io|
#       io << prox

#       seg_count.times do |s_i|
#         off = s_i &* 3
#         idx = 0

#         while idx < 3
#           ch1 = digs.unsafe_fetch(off &+ idx)

#           if ch1 == ' '
#             idx += 1
#             next
#           end

#           if off > 0
#             io << ' '
#             io << "lẻ " if idx > 0
#           end

#           case idx
#           when 0
#             io << to_vstr(ch1)
#             io << " trăm"
#           when 1 then ch1 == '１' ? (io << "mười") : (io << to_vstr(ch1) << " mươi")
#           else        io << to_vstr(ch1)
#           end

#           break
#         end

#         case idx
#         when 3 then next
#         when 2 # just print unit
#         when 1
#           ch3 = digs.unsafe_fetch(off &+ 2)
#           io << to_vstr(ch3) if ch3 != ' '
#         when 0
#           ch2 = digs.unsafe_fetch(off &+ 1)
#           ch3 = digs.unsafe_fetch(off &+ 2)

#           if ch2 != ' '
#             ch2 == '１' ? (io << " mười") : (io << ' ' << to_vstr(ch2) << " mươi")
#             io << ' ' << to_vstr(ch3) if ch3 != ' '
#           elsif ch3 != ' '
#             io << " lẻ " << to_vstr(ch3)
#           end
#         end

#         unit = seg_count &- s_i &- 1
#         io << unit_vstr(unit) if unit > 0
#       end
#     end
#   end

#   private def unit_vstr(unit : Int32)
#     String.build do |io|
#       rem = unit % 3
#       io << (rem == 1 ? " nghìn" : " triệu") if rem > 0
#       (unit // 3).times { io << " tỉ" }
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
