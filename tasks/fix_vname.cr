require "./shared/bootstrap"

CV::Yslist.query.each do |yslist|
  yslist.set_name(yslist.zname)
  yslist.save!
end

# set4 = Set(String).new
# set5 = Set(String).new
# set6 = Set(String).new
# set8 = Set(String).new

# CV::Nvinfo.query.with_author.each do |x|
#   bhash = x.bhash
#   set8 << bhash

#   # bhash_2 = CV::UkeyUtil.digest32(x.author.zname, 3) + CV::UkeyUtil.digest32(x.zname, 5)
#   set6 << bhash[0..5] + x.hslug[0..1]
#   set5 << bhash[0..3] + x.hslug[0..3]
#   set4 << bhash[0..3] + x.hslug[0..4]
# end

# puts "8: #{set8.size}, #{set8.first}"
# puts "6: #{set6.size}, #{set6.first}"
# puts "5: #{set5.size}, #{set5.first}"
# puts "4: #{set4.size}, #{set4.first}"
