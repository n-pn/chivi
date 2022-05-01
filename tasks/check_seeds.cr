require "./shared/bootstrap"

sname = ARGV.first? || "ptwxz"
zseed = CV::SnameMap.map_int(sname)
count = Set(String).new

CV::Nvinfo.query.filter_zseeds(sname).order_by(weight: :desc).each do |nvinfo|
  zseeds = nvinfo.zseeds.reject!(&.in?(0, 63, 22))
  count << nvinfo.bslug if zseed == zseeds.first?
end

puts "count #{sname}: #{count.size}"
puts count.first(30)
