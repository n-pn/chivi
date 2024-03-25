require "sqlite3"

DIR = "/2tb/zroot/wn_db"

# def check_sname(sname : String)
#   mapping = DB.open("sqlite3:var/zroot/mapping.db3") do |db|
#     db.query_all("select sn_id from mapping where sname = $1", sname.lchop('!'), as: Int32).to_set
#   end

#   sn_ids = Dir.children("#{DIR}/#{sname}").map do |fname|
#     fname.split(/\D/, 2).first.to_i
#   end.uniq!

#   missing = sn_ids.reject(&.in?(mapping))
#   puts "[#{sname}] total: #{sn_ids.size}, missing: #{missing.size}"

#   return if missing.empty?
#   File.write("/2tb/working/missing/#{sname}.txt", missing.join('\n'))
# end

# Dir.each_child(DIR) do |sname|
#   check_sname sname if sname.starts_with?('!')
# end

Dir.glob("/2tb/working/missing/*.txt") do |fpath|
  sn_ids = File.read_lines(fpath)
  sname = File.basename(fpath, ".txt")

  sn_ids.each do |sn_id|
    has_text = DB.open("sqlite3:#{DIR}/#{sname}/#{sn_id}-zdata.db3") do |db|
      db.query_one "select count(ch_no) from czdata where ztext is not null", as: Int32
    end

    if has_text > 0
      puts "#{sname}/#{sn_id} has #{has_text} chap, can be recovered!"
      File.open("/2tb/working/to_save.txt", "a", &.puts("#{sname}\t#{sn_id}"))
    end
  end
end
