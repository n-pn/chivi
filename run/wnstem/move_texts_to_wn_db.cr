require "pg"
require "sqlite3"
ENV["CV_ENV"] = "production"
require "../../src/cv_env"

PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

MTIME = Time.utc(2023, 9, 29).to_unix

WN_SQL = <<-SQL
  select wn_id, chap_total from wnseeds
  where wn_id >= 0 and chap_total > 0 and sname = $1 and mtime >= $2
SQL

CH_SQL = "select cksum from chinfos where cksum <> '' and ch_no <= $1"

def move_dir(sname : String)
  inputs = PGDB.query_all WN_SQL, sname, MTIME, as: {Int32, Int32}

  inputs.each do |wn_id, chmax|
    db_path = "var/stems/wn#{sname}/#{wn_id}.db3"

    to_copy = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
      db.query_all(CH_SQL, chmax, as: String).to_set
    rescue
      Set(String).new
    end

    next if to_copy.empty?
    puts "#{db_path}: #{to_copy.size}"

    raw_dir = "var/wnapp/chtext/#{wn_id}"
    nlp_dir = "var/wnapp/nlp_wn/#{wn_id}"
    vtl_dir = "var/wnapp/chtran/#{wn_id}"

    out_dir = "var/texts/wn#{sname}/#{wn_id}"
    Dir.mkdir_p(out_dir)

    Dir.each_child(raw_dir) do |fpath|
      cksum = fpath.split('-')[1]
      next unless to_copy.includes?(cksum)

      File.copy("#{raw_dir}/#{fpath}", "#{out_dir}/#{fpath.sub(".txt", ".raw.txt")}")
    end

    if File.directory?(nlp_dir)
      Dir.each_child(nlp_dir) do |fpath|
        cksum = fpath.split('-')[1]
        next unless to_copy.includes?(cksum)

        File.copy("#{nlp_dir}/#{fpath}", "#{out_dir}/#{fpath}")
      end
    end

    if File.directory?(vtl_dir)
      Dir.each_child(vtl_dir) do |fpath|
        cksum = fpath.split('-')[1]
        next unless to_copy.includes?(cksum)
        File.copy("#{vtl_dir}/#{fpath}", "#{out_dir}/#{fpath}")
      end
    end
  end
end

move_dir("~chivi")
move_dir("~draft")
move_dir("~avail")
