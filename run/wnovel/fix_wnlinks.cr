require "colorize"
require "../../src/_data/wnovel/wnlink"

input = PGDB.query_all <<-SQL, as: {String, String}
  select link, name from wnlinks;
  SQL

output = {} of String => String

input.each do |(link, name)|
  new_name = CV::Wnlink.extract_name(link)
  puts link if new_name.empty?

  next if new_name == name
  PGDB.exec <<-SQL, link, new_name
    update wnlinks set name = $2 where link = $1
    SQL
end
