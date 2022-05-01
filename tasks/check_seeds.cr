require "./shared/bootstrap"

sname = ARGV.first? || "ptwxz"
zseed = CV::SnameMap.map_int(sname)
count = Set(String).new

CV::Nvinfo.query.filter_zseeds(sname).order_by(weight: :desc).each do |nvinfo|
  zseeds = nvinfo.zseeds.reject { |x| x == 0 || x == 63 }
  count << nvinfo.bslug if zseeds == [zseed]
end

puts "count #{sname}: #{count.size}"
puts count.first(30)
