require "../src/cv_env"
require "pg"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

OUT = "var/ysapp/repls-txt"
SQL = "update ysrepls set vhtml = $1 where origin_id = $2"

dirs = Dir.glob("#{OUT}/*-vi")
dirs.each_with_index(1) do |dir, idx|
  puts "- #{idx}/#{dirs.size}: #{dir}"

  PG_DB.transaction do |tx|
    Dir.glob("#{dir}/*.htm") do |path|
      y_rid = File.basename(path, ".htm")
      vhtml = File.read(path)
      tx.connection.exec SQL, vhtml, y_rid
    end
  end
end
