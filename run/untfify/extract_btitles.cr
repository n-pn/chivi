require "../../src/_data/_data"
require "../../src/_util/book_util"

titles = PGDB.query_all "select zname from btitles where id > 0 order by id asc", as: String

hash = {} of String => Array(String)
titles.each do |btitle|
  clean_title = BookUtil.fix_btitle(btitle).gsub(/\p{P}/, "")
  list = hash[clean_title] ||= [] of String
  list << btitle
end

count = 0

hash.each do |key, val|
  next if val.size < 2
  count += 1
  puts val
end

puts count
