require "pg"
require "sqlite3"

ENV["CV_ENV"] = "production"
require "../../src/cv_env"

PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

# WN_SQL = "select wn_id from wnseeds where wn_id >= 0 and chap_total > 0 and sname = $1"
MTIME = Time.utc(2023, 9, 20).to_unix

WN_SQL = "select sn_id, wn_id from rmstems where sname = $1 and wn_id > 0"
CH_SQL = "select ch_no || '-' || cksum from chinfos where cksum <> ''"

def move_dir(sname : String)
  inputs = PGDB.query_all WN_SQL, sname, as: {String, Int32}

  inputs.each do |sn_id, wn_id|
    db_path = "var/stems/rm#{sname}/#{sn_id}-cinfo.db3"
    next unless File.file?(db_path)

    existed = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
      db.query_all(CH_SQL, as: String).to_set
    rescue ex
      puts "#{db_path} is invalid: #{ex}"
      File.delete?(db_path)
      Set(String).new
    end

    next if existed.empty?
    puts "#{db_path}: #{existed.size}"

    inp_dir = "var/texts/wn~avail/#{wn_id}"
    next unless File.directory?(inp_dir)

    out_dir = "var/texts/rm#{sname}/#{sn_id}"
    Dir.mkdir_p(out_dir)

    inp_files = Dir.children(inp_dir)
    puts "- input: #{inp_files.size}"

    inp_files.each do |inp_file|
      inp_name = inp_file.split('-').first(2).join('-')
      next unless inp_name.in?(existed)

      inp_path = "#{inp_dir}/#{inp_file}"
      out_path = "#{out_dir}/#{inp_file}"

      if File.file?(out_path)
        next if File.same?(inp_path, out_path)
        File.delete(out_path)
      end

      begin
        File.link(inp_path, out_path)
      rescue ex
        Log.error { ex }
        File.copy(inp_path, out_path)
      end
    end
  end
end

# move_dir("!hetushu.com")
ARGV.each do |sname|
  move_dir(sname) if sname.starts_with?('!')
end
