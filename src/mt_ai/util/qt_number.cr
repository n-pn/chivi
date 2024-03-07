# struct MT::QtNumber
#   HAN_TO_INT = {
#     '零' => 10,
#     '〇' => 10,
#     '一' => 11,
#     '二' => 12,
#     '两' => 12,
#     '三' => 13,
#     '四' => 14,
#     '五' => 15,
#     '六' => 16,
#     '七' => 17,
#     '八' => 18,
#     '九' => 19,
#     '几' => 21,
#     '十' => -1,
#     '百' => -2,
#     '千' => -3,
#     '万' => -4,
#     '亿' => -8,
#     '兆' => -12,
#   }

#   PRFX_TO_VI = {
#     '来' => "chừng ",
#     '余' => "trên ",
#     '多' => "hơn ",
#   }

#   DIGIT_TO_VI = {"không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín", "mười", "mấy"}
#   POWER_OF_E1 = {"một", "mười", "trăm", "nghìn", "mười nghìn", "trăm nghìn", "triệu", "mười triệu", "trăm triệu", "tỉ"}

#   enum Rmode
#     Default; PureDigit; KeepPower
#   end

#   @[Flags]
#   enum Props
#     HasPower; HasDigit; Shorthand
#   end

#   class Unit
#     property digit : Int32
#     property power : Int32

#     def initialize(@digit, @power = 0)
#     end

#     def inspect(io : IO)
#       io << '(' << @digit << ' ' << @power << ')'
#     end
#   end

#   @[AlwaysInline]
#   def self.translate(input : String, scale = 3)
#     new(scale).translate(input)
#   end

#   def initialize(@scale = 3)
#     case scale
#     when 3
#       @to_vi = {"", " mươi", " trăm", " nghìn", " mươi nghìn", " trăm nghìn", " triệu", " mươi triệu", " trăm triệu", " tỉ"}
#     when 4
#       @to_vi = {"", " mươi", " trăm", " nghìn", " vạn", " mươi vạn", " trăm vạn", " nghìn vạn", " ức"}
#     else
#       @to_vi = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
#     end
#   end

#   @[AlwaysInline]
#   def translate(rtxt : String)
#     String.build { |io| translate(io, rtxt) }
#   end

#   def translate(io : IO, rtxt : String)
#     data, prop, prfx, sufx = tokenize(rtxt)
#     data << Unit.new(0, -1)

#     prfx.join(io)

#     if @scale == 1 && prfx.empty? && sufx.empty?
#       render_digit(io, data)
#     else
#       data = fix_power!(data) if prop.has_power?
#       render_power(io, data)
#     end

#     sufx.join(io)
#   end

#   def tokenize(rtxt : String)
#     data = [] of Unit
#     prop = Props::None
#     prfx = [] of String
#     sufx = [] of Char

#     rtxt.each_char do |char|
#       case
#       when char.in?('0'..'9')
#         prop |= :has_digit
#         data << Unit.new(char.ord - '0'.ord)
#       when char.in?('０'..'９')
#         prop |= :has_digit
#         data << Unit.new(char.ord - '０'.ord)
#       when found = PRFX_TO_VI[char]?
#         prfx << found
#       when !(digit = HAN_TO_INT[char]?)
#         sufx << char
#       when digit >= 0
#         data << Unit.new(digit, 0)
#       else
#         prop |= :has_power
#         power = -digit

#         if data.empty?
#           data << Unit.new(101, power)
#         else
#           data.reverse_each do |unit|
#             break if unit.power > power
#             unit.power = 0 if unit.power < 0
#             unit.power += power
#           end
#         end
#       end
#     end

#     # handle special case 二万五 etc
#     if data.size > 1 && data[-1].power == 0 && data[-2].power > 1
#       data[-1].power = data[-2].power - 1
#       prop |= :shorthand
#     end

#     {data, prop, prfx, sufx}
#   end

#   private def fix_power!(data : Array(Unit))
#     data.each_cons_pair do |curr, succ|
#       curr.digit = 110 if curr.digit == 10

#       case
#       when curr.power == succ.power
#         curr.power = 0
#       when curr.power == succ.power + 1 && succ.power % @scale == 0
#         case succ.digit
#         when 11 then succ.digit = 111
#         when 15 then succ.digit = 115
#         end
#       end
#     end

#     i = data.size - 1

#     while i >= 0
#       curr = data[i]
#       i &-= 1

#       prev_power = curr.power
#       next if prev_power < @scale

#       power = prev_power // @scale * @scale
#       j = i

#       while j >= 0
#         node = data[j]
#         break if node.power > power * 2

#         if node.power == prev_power
#           node.power = 0
#         elsif node.power != 0
#           prev_power = node.power
#           node.power -= power
#         end

#         j &-= 1
#       end
#     end

#     data
#   end

#   private def render_digit(io : IO, data : Array(Unit)) : Nil
#     data.each_cons_pair do |curr, succ|
#       case curr.digit
#       when 10
#       when 20
#         curr.digit = 1
#         curr.power += 1
#       when 101
#         curr.digit = 1
#       end

#       case curr.digit
#       when .< 10 then io << curr.digit
#       when .< 21 then io << (curr.digit - 10)
#       else            io << '~'
#       end

#       succ.power = curr.power - 1 if succ.digit == 10
#       (curr.power - succ.power - 1).times { io << '0' }
#     end
#   end

#   private def render_power(io : IO, data : Array(Unit))
#     data.each_cons_pair do |curr, succ|
#       render_pair(io, curr, succ)
#       io << ' ' if pad_space?(curr, succ)
#     end
#   end

#   private def pad_space?(curr, succ)
#     return false if succ.power < 0
#     return true if curr.digit > 9 || succ.digit > 9
#     curr.power > succ.power + 1
#   end

#   private def render_pair(io : IO, curr : Unit, succ : Unit)
#     case curr.digit
#     when .< 10
#       io << curr.digit
#     when 11
#       if curr.power == 1
#         io << "mười"
#         return
#       else
#         io << "một"
#       end
#     when 101
#       curr.power, mod = curr.power.divmod(9)
#       io << POWER_OF_E1[mod]
#     when 110 then io << "linh"
#     when 111 then io << "mốt"
#     when 115 then io << "lăm"
#     else
#       io << DIGIT_TO_VI[curr.digit - 10]
#     end

#     # if @digit < 10 && @power % scale != 0
#     #   div, mod = @power.divmod(scale)
#     #   mod.times { io << '0' }
#     #   @power = div * scale
#     #   return if @power == 0
#     # end

#     div, mod = curr.power.divmod(@to_vi.size)

#     if curr.digit > 9 # hanzi
#       io << @to_vi[mod]
#     elsif mod > @scale
#       div_2, mod_2 = mod.divmod(@scale)

#       mod_2.times { io << '0' }
#       io << @to_vi[div_2 * @scale]
#     elsif digit_pair?(curr, succ)
#       (curr.power - succ.power % @scale - 1).times { io << '0' }
#     else
#       io << @to_vi[mod]
#     end

#     div.times { io << @to_vi.last }
#   end

#   private def digit_pair?(curr, succ)
#     return false if succ.power < 0 || succ.digit > 9
#     curr.power >= succ.power % @scale + 1
#   end

#   # puts translate("1万")
#   # puts translate("六十七万")
#   # puts translate("六万五")
#   # puts translate("2百", :pure_digit)
#   # puts translate("1万6千")
#   # puts translate("124", :pure_digit)
#   # puts translate("一千一百零三", :pure_digit)
#   # puts translate("五百一十五")
# end
