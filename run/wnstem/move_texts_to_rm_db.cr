require "pg"
require "sqlite3"

ENV["CV_ENV"] = "production"
require "../../src/cv_env"

PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

# WN_SQL = "select wn_id from wnseeds where wn_id >= 0 and chap_total > 0 and sname = $1"
MTIME = Time.utc(2023, 9, 20).to_unix

WN_SQL = <<-SQL
  select wn_id from wnseeds
  where wn_id >= 0 and chap_total > 0 and sname = $1 and mtime >= $2
SQL

CH_SQL = "select ch_no, cksum from chinfos where cksum <> ''"

def move_dir(sname : String)
  wn_ids = PGDB.query_all WN_SQL, sname, MTIME, as: Int32

  wn_ids.each do |wn_id|
    db_path = "var/stems/rm#{sname}/#{wn_id}.db3"

    existed = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
      db.query_all CH_SQL, as: {Int32, String}
    rescue
      [] of {Int32, String}
    end

    next if existed.empty?
    puts "#{db_path}: #{existed.size}"

    raw_dir = "var/wnapp/chtext/#{wn_id}"
    nlp_dir = "var/wnapp/nlp_wn/#{wn_id}"

    out_dir = "var/texts/rm#{sname}/#{wn_id}"
    Dir.mkdir_p(out_dir)

    existed.each do |ch_no, cksum|
      Dir.glob("#{raw_dir}/#{ch_no}-#{cksum}-*.txt").each do |inp_file|
        out_file = inp_file.sub(raw_dir, out_dir).sub(".txt", ".raw.txt")
        File.copy(inp_file, out_file)
      end

      Dir.glob("#{nlp_dir}/#{ch_no}-#{cksum}-*").each do |inp_file|
        out_file = inp_file.sub(nlp_dir, out_dir)
        File.copy(inp_file, out_file)
      end
    end
  end
end

snames = PGDB.query_all "select distinct(sname) from wnseeds where sname like '!%'", as: String

snames.each do |sname|
  move_dir(sname)
rescue ex
  puts ex
end