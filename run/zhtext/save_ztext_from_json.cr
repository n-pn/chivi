# require "json"
# require "colorize"

# record Zdata, ch_no : Int32, chdiv : String, parts : String, mtime : Int64 do
#   include JSON::Serializable
# end

# def export(txt_dir)
#   chaps = Dir.glob("#{txt_dir}/*.json").map do |file|
#     Zdata.from_json(File.read(file))
#   end

#   puts "#{txt_dir}: #{chaps.size} files"
#   return if chaps.empty?

#   sname = File.basename(File.dirname(txt_dir)).sub(/^wn|rm|up/, "")
#   sn_id = File.basename(txt_dir)

#   out_dir = "/2tb/zroot/ztext/#{sname}/#{sn_id}"
#   Dir.mkdir_p(out_dir)

#   chaps.sort_by!(&.mtime).each do |zchap|
#     out_file = "#{out_dir}/#{zchap.ch_no}0.zh"
#     File.write(out_file, "///#{zchap.chdiv}\n#{zchap.parts}")
#     mtime = Time.unix(zchap.mtime)
#     File.utime(mtime, mtime, out_file)
#   end

#   `zip -rjyomq '#{out_dir}.zip' '#{out_dir}'`
# end

# INP = "/2tb/var.chivi/texts"

# snames = ARGV.reject(&.starts_with?('-'))

# if ARGV.includes?("--up")
#   snames.concat Dir.children(INP).select(&.starts_with?("up"))
# end

# if ARGV.includes?("--rm")
#   snames.concat Dir.children(INP).select(&.starts_with?("rm"))
# end

# snames.each do |sname|
#   sn_ids = Dir.children("#{INP}/#{sname}")

#   puts "#{sname}: #{sn_ids.size} files"

#   sn_ids.each do |sn_id|
#     export("#{INP}/#{sname}/#{sn_id}")
#   rescue ex
#     puts ex.colorize.red
#   end
# end
