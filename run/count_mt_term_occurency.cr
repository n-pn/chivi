require "sqlite3"

DIR = "var/texts/anlzs/out"

select_sql = "select distinct(zstr) from terms"

counter = Hash(String, Int32).new(0)

files = Dir.children(DIR).sort_by! { |x| File.basename(x, ".db").to_i }

files.each do |path|
  puts path

  DB.open("sqlite3:#{DIR}/#{path}") do |db|
    db.query_each select_sql do |rs|
      counter[rs.read(String)] &+= 1
    end
  end
end

puts counter.size

File.open("var/dicts/inits/count-by-books.tsv", "w") do |file|
  counter = counter.to_a.sort_by!(&.[1].-)
  counter.each do |zstr, occu|
    file << zstr << '\t' << occu << '\n'
  end
end
