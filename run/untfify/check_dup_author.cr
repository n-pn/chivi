require "colorize"
require "../../src/_data/_data"
require "../../src/_util/char_util"
require "../../src/_util/book_util"

authors = {} of String => Int32

PGDB.query_each "select id, zname from authors where id > 0 order by id asc" do |rs|
  id, zname = rs.read(Int32, String)
  authors[zname] = id
end

# authors.each do |author, id|
#   fix_author = BookUtil.fix_author(author)
#   next if author == fix_author

#   PGDB.exec "update authors set zname = $1 where id = $2", fix_author, id
#   puts "(#{id}) [#{author}] => [#{fix_author}]".colorize.green
# rescue err
#   puts [err.message.colorize.red, author, id]
# end

authors.each do |author, old_id|
  fix_author = BookUtil.fix_author(author)

  next if author == fix_author
  next unless fix_id = authors[fix_author]?

  books = PGDB.query_all "select id, btitle_id from wninfos where author_id = $1", old_id, as: {Int32, Int32}
  next if books.empty?

  puts "[#{old_id}] (#{author}) => [#{fix_id}] (#{fix_author})".colorize.yellow

  books.each do |wn_id, btitle_id|
    if new_id = PGDB.query_one?("select id from wninfos where btitle_id = $1 and author_id = $2", btitle_id, fix_id, as: Int32)
      puts "- book: #{wn_id} => #{new_id}"
      PGDB.exec "update wninfos set subdue_id = $1 where id = $2", new_id, wn_id
    else
      PGDB.exec "update wninfos set author_id = $1 where id = $2", fix_id, wn_id
    end
  rescue err
    puts [err.message.colorize.red, fix_author, wn_id]
  end
end
