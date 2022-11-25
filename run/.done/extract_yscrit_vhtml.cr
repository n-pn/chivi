require "db"
require "pg"
require "amber"

db = DB.open(Amber.settings.database_url)
at_exit { db.close }

max_ysbook_id = db.scalar("select max(id) from ysbooks").as(Int64).to_i
puts max_ysbook_id

# log_file = "tmp/yscrits-vhtml.log"
# exported = File.read_lines(log_file).map(&.to_i).to_set

# query = "select origin_id, vhtml from yscrits where ysbook_id = $1"

# 1.upto(max_ysbook_id) do |ysbook_id|
#   next if exported.includes?(ysbook_id)

#   out_dir = "var/ysapp/crits.tmp/#{ysbook_id}-vi"
#   Dir.mkdir_p(out_dir)

#   count = 0

#   db.query_each(query, args: [ysbook_id]) do |rs|
#     uuid, vhtml = rs.read(String, String)
#     File.write("#{out_dir}/#{uuid}.htm", vhtml)
#     count &+= 1
#   end

#   puts "#{count} entries saved to #{out_dir}"
#   File.open(log_file, "a", &.puts(ysbook_id))

#   zip_path = "var/ysapp/crits/#{ysbook_id}-vi.zip"
#   `zip -rjuq "#{zip_path}" #{out_dir}`
# end

def clean_html(book_id : Int32)
  zip_path = "var/ysapp/crits/#{book_id}-vi.zip"
  htm_path = "var/ysapp/crits.tmp/#{book_id}-vi"

  puts "cleaning: #{zip_path}"

  Dir.glob("#{htm_path}/*.htm").each do |file|
    next if File.size(file) > 10
    text = File.read(file)

    if text.in?("", "<p></p>", "<p>$$$</p>")
      puts "File deleted: #{file}".colorize.red
      File.delete(file)
    else
      puts text.colorize.yellow
    end
  end

  `zip -FS -jrq "#{zip_path}" #{htm_path}`
end

1.upto(max_ysbook_id) do |ysbook_id|
  clean_html(ysbook_id)
end
