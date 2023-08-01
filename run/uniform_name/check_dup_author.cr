require "../../src/_data/_data"
require "../../src/_util/char_util"

titles = PGDB.query_all "select zname from authors where id > 0", as: String

hash = {} of String => Array(String)

titles.each do |title|
  clean_title = title.gsub(/\p{P}/, "")
  clean_title = CharUtil.canonicalize(clean_title)

  list = hash[clean_title] ||= [] of String
  list << title
end

hash.reject! do |key, val|
  val.size < 2
end

def get_titles(zname : String)
  PGDB.query_all <<-SQL, zname, as: String
    select zname from btitles
    where id in (
      select btitle_id from wninfos
      where author_id = (select id from authors where zname = $1 limit 1)
    )
  SQL
end

hash.each_value do |names|
  names.each do |zname|
    puts "#{zname} => #{get_titles(zname)}"
  end

  puts "-----"
end
