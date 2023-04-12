require "json"
files = Dir.glob "var/users/mtlogs/*.log"

record Stat, uname : String, c_len : Int32, wn_id : Int32 do
  include JSON::Serializable
end

users = Hash(String, Int32).new 0
books = Hash(Int32, Int32).new 0

files.each do |file|
  puts file

  File.each_line(file) do |line|
    next if line.empty?

    stat = Stat.from_json(line)

    users[stat.uname] += stat.c_len
    books[stat.wn_id] += stat.c_len
  end
end

puts users.sum(&.[1])

puts users.keys, users.size
puts books.keys, books.size

puts users.to_a.sort_by(&.[1].-)
puts books.to_a.sort_by(&.[1].-)
