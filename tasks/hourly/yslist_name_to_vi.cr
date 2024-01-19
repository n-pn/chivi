require "./yousuu_shared"

TABLE = "yslists"

SELECT_SQL = <<-SQL
select id, zname as ztext from #{TABLE}
where zname <> '' and vname_bd is null
limit 1000
SQL

UPDATE_SQL = "update #{TABLE} set vname_bd = $1 where id = $2"

CACHE_DIR = "/2tb/zroot/ydata/yslist"

item_count = 0
char_total = 0

(1..).each do |index|
  input = PGDB.query_all(SELECT_SQL, as: Input).shuffle!
  break if input.empty?
  item_count += input.size

  trans, char_total = Input.translate_batch(input, "bd_zv", index, char_total, "yslist")

  orig_size = input.size
  raise "size mismatch #{trans.size} vs #{orig_size}" if trans.size != orig_size

  input.each_with_index do |input, index|
    PGDB.exec UPDATE_SQL, trans[index], input.id
  end

  puts "- #{index}: #{item_count} resolved".colorize.yellow
rescue ex
  Log.warn { ex.message.colorize.yellow }
  sleep 10.seconds
end
