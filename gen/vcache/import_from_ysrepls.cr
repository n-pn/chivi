ENV["CV_ENV"] = "production"

require "../../src/_data/_data"
require "../../src/_util/text_util"
require "../../src/mt_sp/data/v_cache"

record Input, id : Int32, ztext : String, vi_bd : String do
  include DB::Serializable

  getter lines : Array(String) do
    @ztext.lines.compact_map do |line|
      line = line
        .gsub('\u003c', '<')
        .gsub(/\p{Cc}/, "")
        .strip
      line unless line.empty?
    end
  end
end

SELECT_SQL = <<-SQL
select id, ztext, vi_bd from ysrepls
where ztext <> '' and vi_bd is not null
SQL

inputs = PGDB.query_all SELECT_SQL, as: Input
puts "total: #{inputs.size}"

mtime = TimeUtil.cv_mtime Time.local(2024, 1, 5)

inputs.each_slice(100) do |slice|
  items = [] of SP::VCache

  slice.each do |input|
    raws = input.lines
    vals = input.vi_bd.lines

    if raws.size != vals.size
      Log.warn { "#{input.id} has mismatch size! (#{raws.size}, #{vals.size})" }
      File.open("var/zroot/ysrepl-vi_bd-mismatch.log", "a", &.puts(input.id))
      next
    end

    raws.zip(vals) do |raw, val|
      raw = CharUtil.to_canon(raw, false).strip('　')
      rid = SP::VCache.gen_rid(raw)

      items << SP::VCache.new(rid, :ztext, raw, mcv: 0)
      items << SP::VCache.new(rid, :bd_zv, val, mcv: mtime)
    end
  end

  ZR_DB.transaction do |tx|
    items.each(&.upsert!(db: tx.connection))
  end

  Log.info { "\t#{items.size} cached!" }
end
