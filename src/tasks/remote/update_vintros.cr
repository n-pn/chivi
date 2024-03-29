require "pg"
require "colorize"

ENV["CV_ENV"] ||= "production"

require "../../cv_env"
PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

require "../../mt_v1/core/m1_core"

def convert(engine, ztext : String)
  String.build do |io|
    ztext.each_line do |line|
      line = line.strip
      puts line
      engine.cv_plain(line, true).to_txt(io) unless line.empty?
    end
  end
end

SELECT_SQL = <<-SQL
  select wn_id, sname, sn_id, intro_zh
  from rmstems
  where intro_zh <> '' and intro_vi = ''
  order by rtime desc
  SQL

UPDATE_SQL = <<-SQL
  update rmstems set intro_vi = $1 where sname = $2 and sn_id = $3
  SQL

inputs = PGDB.query_all SELECT_SQL, as: {Int32, String, String, String}

puts "inputs: #{inputs.size}"

inputs.group_by(&.[0]).each do |wn_id, rstems|
  puts "- #{wn_id}: #{rstems.size}"

  cv_mt = M1::MtCore.init(udic: wn_id)
  db = PGDB

  rstems.each do |_, sname, sn_id, intro_zh|
    puts({sname, sn_id})

    intro_vi = convert(cv_mt, intro_zh)
    db.exec UPDATE_SQL, intro_vi, sname, sn_id
  rescue ex
    puts intro_zh
  end
end
