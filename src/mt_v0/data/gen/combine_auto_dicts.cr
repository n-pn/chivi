# require "json"
# require "../vp_init"

# DIR = "var/texts/anlzs/out"

# ZPOS_UPSERT = <<-SQL
#   insert into defns (zstr, zpos) values ($1, $2)
#   on conflict (zstr) do update set zpos = excluded.zpos
# SQL

# def export_zpos(db_path : String)
#   puts "ZPOS: #{db_path}"
#   counters = {} of String => Counter

#   DB.open("sqlite3:#{db_path}") do |db|
#     db.query_each ZPOS_SELECT do |rs|
#       zstr, zpos, occu = rs.read(String, String, Int32)
#       counter = counters[zstr] ||= Counter.new
#       counter[zpos] ||= occu
#     end
#   end

#   wn_id = File.basename(db_path, ".db")

#   repo = MT::VpInit.repo(wn_id)
#   repo.db.exec "begin"

#   counters.each do |zstr, counter|
#     repo.db.exec ZPOS_UPSERT, zstr, counter.to_json
#   end

#   repo.db.exec "commit"
# end
