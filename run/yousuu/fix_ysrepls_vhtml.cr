require "../../src/_data/_data"
require "../../src/mt_v1/core/m1_core"

input = PGDB.query_all <<-SQL, as: {Int32, String, Int32}
  select ysrepls.id, ysrepls.ztext, yscrits.nvinfo_id
  from ysrepls inner join yscrits on ysrepls.yscrit_id = yscrits.id
  where ysrepls.vhtml = ''
  SQL

puts "input: #{input.size}"

engines = Hash(Int32, M1::MtCore).new { |h, k| h[k] = M1::MtCore.init(udic: k) }

input.each_with_index(1) do |(yr_id, ztext, wn_id), index|
  puts "- #{index}/#{input.size}: #{yr_id} => #{wn_id}"

  engine = engines[wn_id]

  vhtml = String.build do |io|
    ztext.each_line do |line|
      line = line.strip
      next if line.empty?

      io << "<p>"
      engine.cv_plain(line, true).to_txt(io)
      io << "</p>\n"
    end
  end

  PGDB.exec "update ysrepls set vhtml = $1 where id = $2", vhtml, yr_id
end
