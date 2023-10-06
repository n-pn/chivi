require "pg"
require "colorize"
require "../../src/cv_env"

PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

require "../../src/mt_v1/core/m1_core"

def convert(engine, ztext : String)
  String.build do |io|
    ztext.each_line do |line|
      line = line.strip
      next if line.empty?

      io << "<p>"
      engine.cv_plain(line, true).to_txt(io)
      io << "</p>\n"
    end
  end
end

input = PGDB.query_all <<-SQL, as: {Int32, String, Array(String), Int32}
  select id, ztext, ztags, nvinfo_id
  from yscrits
  where vhtml = '' and ztext <> ''
  SQL

puts "input: #{input.size}"

engines = Hash(Int32, M1::MtCore).new { |h, k| h[k] = M1::MtCore.init(udic: k) }

input.each_with_index(1) do |(yc_id, ztext, ztags, wn_id), index|
  puts "- #{index}/#{input.size}: #{yc_id} => #{wn_id}"

  cv_mt = engines[wn_id]

  vhtml = convert(cv_mt, ztext)
  vtags = ztags.map { |ztag| cv_mt.cv_plain(ztag).to_txt }

  PGDB.exec <<-SQL, vhtml, vtags, yc_id
    update yscrits
    set vhtml = $1, vtags = $2
    where id = $3
    SQL

rescue ex
  puts ex
end
