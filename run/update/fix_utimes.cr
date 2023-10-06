# require "../shared/bootstrap"

# CV::Wninfo.query.each do |nvinfo|
#   bseeds = nvinfo.nvseeds.to_a.reject(&.zseed.in?(0, 1, 4, 63))

#   if bseeds.empty?
#     utime = nvinfo.ysbook.try(&.utime) || nvinfo.utime
#   else
#     utime = bseeds.max_of(&.utime)
#   end

#   nvinfo.update(utime: utime)
# end
