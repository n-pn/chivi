require "../_data/_data"
require "../zroot/author"
require "../zroot/ysbook"
require "../zroot/tubook"

OUT_DB = ZR::Author.db

SELECT_STMT = "select id, zname, vname from authors where id >= $1 and id <= $2"

record Author, id : Int32, zname : String, vname : String do
  include DB::Serializable
end

existed = Set(String).new

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  inputs = PGDB.query_all SELECT_STMT, lower, upper, as: Author
  puts "- <authors> block: #{block}, books: #{inputs.size}"

  break if inputs.empty?

  OUT_DB.exec "begin"

  inputs.each do |input|
    entry = ZR::Author.new(input.zname)

    entry.name_mt = input.vname
    entry.wa_id = input.id
    entry.rtime = Time.utc.to_unix
    entry._flag = 0

    entry.upsert!(OUT_DB)
    existed << input.zname
  end

  OUT_DB.exec "commit"
end

SELECT_STMT_2 = "select author, btitle from books where id >= $1 and id <= $2"

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  inputs = ZR::Ysbook.db.query_all SELECT_STMT_2, lower, upper, as: {String, String}
  puts "- <ysbooks> block: #{block}, books: #{inputs.size}"

  break if inputs.empty?

  OUT_DB.exec "begin"

  inputs.each do |author, btitle|
    author, btitle = BookUtil.fix_names(author, btitle)
    next if existed.includes?(author)
    existed << author

    entry = ZR::Author.new(author)
    entry.upsert!(OUT_DB)
  end

  OUT_DB.exec "commit"
end

(0..).each do |block|
  lower = block &* 1000
  upper = lower &+ 999

  inputs = ZR::Tubook.db.query_all SELECT_STMT_2, lower, upper, as: {String, String}
  puts "- <tubooks> block: #{block}, books: #{inputs.size}"

  break if inputs.empty?

  OUT_DB.exec "begin"

  inputs.each do |author, btitle|
    author, btitle = BookUtil.fix_names(author, btitle)
    next if existed.includes?(author)
    existed << author

    entry = ZR::Author.new(author)
    entry.upsert!(OUT_DB)
  end

  OUT_DB.exec "commit"
end

puts OUT_DB.query_one("select count(*) from authors", as: Int32)
