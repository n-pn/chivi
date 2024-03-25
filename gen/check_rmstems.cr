ENV["CV_ENV"] = "production"
require "../src/_data/_data"
require "../src/_util/book_util"

authors = File.read_lines("/2tb/working/authors.txt").to_set

rsnames = PGDB.query_all("select distinct(sname) from rmstems", as: String)
puts rsnames

total_count = 0
removed_count = 0

rsnames.each do |sname|
  rmstems = PGDB.query_all <<-SQL, sname, as: {Int32, String}
    select sn_id, author_zh from rmstems where sname = $1
  SQL

  # File.write("/2tb/working/mapping/#{sname}.tsv", rmstems.join('\n') { |x| x.join('\t') })

  removed = rmstems.reject { |_, author| authors.includes? BookUtil.fix_author(author) }
  puts "#{sname} total: #{rmstems.size}, remove:  #{removed.size}"

  total_count += rmstems.size
  removed_count += removed.size
end

puts "total: #{total_count}, removed: #{removed_count}"

wninfos = PGDB.query_all "select id, author_zh from wninfos", as: {Int32, String}

removed = wninfos.reject { |_, author| authors.includes? BookUtil.fix_author(author) }
puts "total: #{wninfos.size}, removed: #{removed.size}, remain: #{wninfos.size - removed.size}"

# puts PGDB.query_one "select count(distinct(wn_id)) from rmstems", as: Int64
