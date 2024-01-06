require "colorize"

ENV["CV_ENV"] ||= "production"
require "../../src/_data/_data"
require "../../src/mt_sp/data/qt_data"

TABLE = "ysrepls"

SELECT_SQL = <<-SQL
select id, ztext from #{TABLE}
where ztext <> '' and vi_bd is null
limit 100
SQL

UPDATE_SQL = "update #{TABLE} set vi_bd = $1 where id = $2"

record Input, id : Int32, ztext : String do
  include DB::Serializable

  getter lines : Array(String) do
    @ztext.lines.compact_map do |line|
      line = line.gsub('\u003c', '<').gsub(/\p{Cc}/, "").strip
      line unless line.empty?
    end
  end
end

def split_text(input : Array(Input))
  texts = [[] of String]

  total = 0
  limit = 1000

  input.each do |ycrit|
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

CACHE_DIR = "/2tb/zroot/ydata/ysrepl"

def translate_one(input : Input)
  char_count = input.ztext.size
  trans, mtime = SP::QtData.from_ztext(input.lines, cache_dir: CACHE_DIR).get_vtran("bd_zv")

  if trans.size == input.lines.size
    PGDB.exec UPDATE_SQL, trans.join('\n'), input.id
  else
    Log.warn { "size mismatch!!" }
  end

  Log.info { " cached at: #{Time.unix(mtime)}" }
  Log.info { "- #{trans.size} lines".colorize.green }

  char_count
end

def translate_batch(input : Array(Input), loop_index = 1)
  char_total = 0

  texts = split_text(input)
  trans = [] of String

  texts.each_with_index(1) do |lines, index_2|
    char_count = lines.sum(&.size) + lines.size
    char_total += char_count

    Log.info { "<#{loop_index}-#{index_2}> #{char_count} chars".colorize.cyan }

    vtext, mtime = SP::QtData.from_ztext(lines, cache_dir: CACHE_DIR).get_vtran("bd_zv")
    trans.concat(vtext)

    Log.info { " cached at: #{Time.unix(mtime)}" }
    Log.info { "- #{trans.size} lines, total chars: #{char_total}".colorize.green }
  end

  orig_size = input.sum(&.lines.size)
  raise "size mismatch #{trans.size} #{orig_size}" if trans.size != orig_size

  start = 0
  input.each do |emtry|
    count = emtry.lines.size
    vi_bd = trans[start, count]
    PGDB.exec UPDATE_SQL, vi_bd.join('\n'), emtry.id
    start += count
  end

  char_total
end

char_total = 0
item_count = 0
loop_index = 0

loop do
  input = PGDB.query_all(SELECT_SQL, as: Input)
  break if input.empty?

  loop_index += 1
  item_count += input.size

  large, small = input.partition(&.ztext.size.> 3000)
  large.each { |entry| char_total += translate_one(entry) }
  char_total += translate_batch(small, loop_index)
rescue ex
  Log.warn { ex.message.colorize.red }
  sleep 10.seconds
end
