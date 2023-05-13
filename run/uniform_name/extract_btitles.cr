require "../../src/_data/_data"
require "../../src/_util/char_util"

titles = PGDB.query_all "select zname from btitles where id > 0", as: String

hash = {} of String => Array(String)
titles.each do |title|
  # clean_title = title.gsub(/\p{P}/, "")
  clean_title = CharUtil.canonicalize(title)
  list = hash[clean_title] ||= [] of String
  list << title
end

hash.reject! do |key, val|
  val.size < 2
end

puts hash.size, hash
