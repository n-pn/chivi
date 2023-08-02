# class ZH::ZhChap
#   AVG = 3000
#   MAX = 4500

#   getter c_len = 0
#   getter p_len = 1

#   getter content : String do
#     text = @sbuf.to_s
#     @c_len <= MAX ? text : pad_blank(text).rstrip
#   end

#   def initialize(title : String)
#     @sbuf = String::Builder.new(title)
#   end

#   def <<(line : String) : Nil
#     return if line.empty?
#     @sbuf << '\n' << line
#     @c_len += line.size
#   end

#   def concat(lines : Array(String)) : self
#     lines.each { |l| self << l }
#     self
#   end

#   private def pad_blank(text : String)
#     @p_len = (@c_len &- 1) // AVG &+ 1
#     smax = @c_len // @p_len

#     String.build do |sbuf|
#       c_len = 0

#       text.each_line do |line|
#         sbuf << line << '\n'

#         c_len += line.size
#         next if c_len < smax

#         c_len = 0
#         sbuf << '\n'
#       end
#     end
#   end
# end
