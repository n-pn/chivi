require "colorize"

ENV["CV_ENV"] ||= "production"
require "../../src/_data/_data"
require "../../src/mt_sp/data/qt_data"

record Input, id : Int32, ztext : String do
  include DB::Serializable

  getter lines : Array(String) do
    @ztext.lines.compact_map do |line|
      line = line.gsub('\u003c', '<').gsub(/\p{Cc}/, "").strip
      line unless line.empty?
    end
  end
end

TABLE = "yscrits"

SELECT_SQL = <<-SQL
select id, ztext from #{TABLE}
where ztext <> '' and vi_bd is null
SQL

UPDATE_SQL = "update #{TABLE} set vi_bd = $1 where id = $2"

def split_text(crits : Array(Input))
  texts = [[] of String]

  total = 0
  limit = 4500

  crits.each do |ycrit|
    ycrit.lines.each do |zline|
      texts.last << zline
      total += zline.size + 1

      next if total < limit
      texts << [] of String
      total = 0
    end
  end

  texts.pop if texts.last.empty?
  texts
end

char_total = 0
crit_count = 0

input = PGDB.query_all(SELECT_SQL, as: Input).shuffle!

CACHE_DIR = "/2tb/zroot/ydata/yscrit"

input.each_slice(200).with_index(1) do |crits, index|
  texts = split_text(crits)
  trans = [] of String

  crit_count += crits.size

  texts.each_with_index(1) do |lines, index_2|
    char_count = lines.sum(&.size) + lines.size
    char_total += char_count

    Log.info { "<#{index}-#{index_2}> #{char_count} chars".colorize.cyan }

    vtext, mtime = SP::QtData.from_ztext(lines, cache_dir: CACHE_DIR).get_vtran("bd_zv")
    trans.concat(vtext)

    Log.info { " cached at: #{Time.unix(mtime)}" }
    Log.info { " trans: #{trans.size}, total: #{char_total}".colorize.green }
  end

  orig_size = crits.sum(&.lines.size)
  raise "size mismatch #{trans.size} #{orig_size}" if trans.size != orig_size

  start = 0
  crits.each do |ycrit|
    count = ycrit.lines.size
    vi_bd = trans[start, count]
    PGDB.exec UPDATE_SQL, vi_bd.join('\n'), ycrit.id
    start += count
  end
rescue ex
  Log.warn { ex.message.colorize.red }
  sleep 10.seconds
end
