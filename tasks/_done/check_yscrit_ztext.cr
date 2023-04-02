require "compress/zip"
require "../../src/ysapp/models/*"

# def saved_crit_list(ysbook_id : Int64)
#   zip_file = "var/ysapp/crits/#{ysbook_id}-zh.zip"
#   return [] of String unless File.exists?(zip_file)

#   Compress::Zip::File.open(zip_file) do |zip|
#     zip.entries.map { |x| File.basename(x.filename, ".txt") }
#   end
# end

# max_ysbook_id = CV::Ysbook.query.select("max (id)").scalar(Int64)

# puts "max_id: #{max_ysbook_id}"

# restored = 0
# notsaved = 0
# un_avail = 0

# 1.upto(max_ysbook_id) do |book_id|
#   query = YS::Yscrit.query.where("ysbook_id = ?", book_id)
#   crits = query.select("id", "y_cid", "ztext").to_a
#   next if crits.empty?

#   in_zip = Set(String).new saved_crit_list(book_id)

#   crits.each do |crit|
#     blank = crit.ztext == "$$$" || crit.ztext.empty?
#     saved = in_zip.includes?(crit.y_cid)

#     if saved
#       restored += 1 if blank
#     elsif blank
#       un_avail += 1
#     else
#       notsaved += 1
#     end
#   end

#   puts "- <#{book_id}> notsaved: #{notsaved}, restored: #{restored}, un_avail: #{un_avail}"
# end

total = YS::Yscrit.query.count
count = 0

Dir.glob("var/ysapp/crits/*.zip").each do |zip|
  count += Compress::Zip::File.open(zip, &.entries.size)
  puts "#{zip} : #{count}/#{total}"
end
