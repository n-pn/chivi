require "json"
files = Dir.glob "var/users/mtlogs/*.log"

record Stat, uname : String, c_len : Int32 do
  include JSON::Serializable
end

counter = Hash(String, Int32).new 0

files.each do |file|
  puts file

  File.each_line(file) do |line|
    next if line.empty?

    stat = Stat.from_json(line)

    counter[stat.uname] += stat.c_len
  end
end

counter = counter.to_a
puts counter.sum(&.[1])
puts counter.sort_by(&.[1].-)
