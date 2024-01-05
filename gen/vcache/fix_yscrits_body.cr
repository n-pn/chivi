ENV["CV_ENV"] = "production"

require "../../src/_data/_data"
require "../../src/_util/text_util"
require "../../src/mt_sp/data/v_cache"

record Input, id : Int32, ztext : String, vi_bd : String do
  include DB::Serializable

  getter lines : Array(String) do
    @ztext.lines.compact_map do |line|
      line = line.gsub('\u003c', '<').gsub(/\p{Cc}/, "").strip
      line unless line.empty?
    end
  end
end

SELECT_SQL = <<-SQL
select id, ztext, vi_bd from yscrits
where ztext <> '' and vi_bd is not null and id in (select id from ysrepls)
SQL

inputs = PGDB.query_all SELECT_SQL, as: Input
puts "total: #{inputs.size}"

remove = [] of Int32

inputs.each do |input|
  raws = input.lines
  vals = input.vi_bd.lines
  next if raws.size == vals.size && raws.size > 2
  PGDB.exec "update yscrits set vi_bd = null where id = $1", input.id
end
