require "colorize"
require "../../src/_data/_data"
require "../../src/_util/char_util"
require "../../src/_util/book_util"

btitles = {} of String => Int32

PGDB.query_each "select id, zname from btitles where id > 0 order by id asc" do |rs|
  id, zname = rs.read(Int32, String)
  btitles[zname] = id
end

btitles.each do |btitle, id|
  fix_btitle = BookUtil.fix_btitle(btitle)
  next if btitle == fix_btitle

  PGDB.exec "update btitles set zname = $1 where id = $2", fix_btitle, id
  puts "(#{id}) [#{btitle}] => [#{fix_btitle}]".colorize.green
rescue err
  puts [err.message.colorize.red, btitle, id]
end

# btitles.each do |btitle, old_id|
#   fix_btitle = BookUtil.fix_btitle(btitle)

#   next if btitle == fix_btitle
#   next unless fix_id = btitles[fix_btitle]?

#   books = PGDB.query_all "select id, btitle_id from wninfos where btitle_id = $1", old_id, as: {Int32, Int32}
#   next if books.empty?

#   puts "[#{old_id}] (#{btitle}) => [#{fix_id}] (#{fix_btitle})".colorize.yellow

#   books.each do |wn_id, btitle_id|
#     if other_id = PGDB.query_one?("select id from wninfos where btitle_id = $1 and btitle_id = $2", btitle_id, fix_id, as: Int32)
#       puts "- book: #{wn_id} => #{other_id}"
#     else
#       PGDB.exec "update wninfos set btitle_id = $1 where id = $2", fix_id, wn_id
#     end
#   rescue err
#     puts [err.message.colorize.red, fix_btitle, wn_id]
#   end
# end
