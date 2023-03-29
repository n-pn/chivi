# require "json"
# require "../vp_init"
require "sqlite3"

DIR = "var/anlzs/texsmart/out"

inputs = Dir.glob("#{DIR}/*.db")
inputs.sort_by! { |file| File.basename(file, ".db").to_i }

COUNTS = Hash({String, Int32, String}, Int32).new(0)
MRATES = Hash({String, Int32, String}, Int32).new(0)

inputs.each_with_index(1) do |db_path, idx|
  puts "#{idx} / #{db_path}"

  DB.open("sqlite3:#{db_path}") do |db|
    db.query_each "select zstr, type, ztag, count, mrate from terms" do |rs|
      key = rs.read(String, Int32, String)
      COUNTS[key] += rs.read(Int32)
      MRATES[key] += rs.read(Int32)
    end
  end
end

OUT = DB.open("sqlite3:#{DIR}-all.db?synchronous=normal&journal_mode=WAL")
at_exit { OUT.close }

OUT.exec "begin"

COUNTS.each do |(zstr, type, ztag), count|
  mrate = MRATES[{zstr, type, ztag}]
  OUT.exec <<-SQL, zstr, type, ztag, count, mrate
    replace into terms (zstr, type, ztag, count, mrate) values ($1, $2, $3, $4, $5)
  SQL
end

OUT.exec "commit"

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
