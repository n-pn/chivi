require "./shared"

TABLE = "ysrepls"

SELECT_SQL = <<-SQL
select id, ztext from #{TABLE}
where ztext <> '' and en_bd is null
limit 200
SQL

UPDATE_SQL = "update #{TABLE} set en_bd = $1 where id = $2"

CACHE_DIR = "/2tb/zroot/ydata/ysrepl"

def translate_one(input : Input)
  char_count = input.ztext.size
  trans, mtime = SP::QtData.from_ztext(input.lines, cache_dir: CACHE_DIR).get_vtran("bd_zv")

  if trans.size == input.lines.size
    PGDB.exec UPDATE_SQL, trans, input.id
  else
    Log.warn { "size mismatch!!" }
  end

  Log.info { " cached at: #{Time.unix(mtime)}" }
  Log.info { "- #{trans.size} lines".colorize.green }

  char_count
end

def translate_batch(input : Array(Input), loop_index = 1, char_total = 0)
  trans, char_total = Input.translate_batch(input, "bd_ze", loop_index, char_total, "ysrepl")

  orig_size = input.sum(&.lines.size)
  raise "size mismatch #{trans.size} #{orig_size}" if trans.size != orig_size

  start = 0
  input.each do |entry|
    count = entry.lines.size
    en_bd = trans[start, count]
    PGDB.exec UPDATE_SQL, en_bd.join('\n'), entry.id
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
  char_total = translate_batch(small, loop_index, char_total)
rescue ex
  Log.warn { ex.message.colorize.red }
  sleep 10.seconds
end
