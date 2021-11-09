require "json"
require "colorize"

class Data
  include JSON::Serializable

  getter content : String

  RE = Regex.new("<br ?/?>")

  def ztext
    lines = content.sub(RE, "\n").split("\n")
    lines.map(&.strip).reject(&.empty?)
  end
end

def load_map(file : String)
  res = {} of String => Array(String)
  File.each_line(file) do |line|
    next if line.empty?
    key, val = line.split('\t', 2)
    res[key] = val.empty? ? [] of String : val.split('\t')
  end

  res
end

DIR = "_db/.keeps/yousuu/user_reviews.old"
files = Dir.glob("#{DIR}/**/*.json")

count = 0
fresh = 0

files.each do |file|
  ynvid = File.basename(File.dirname(file))
  ycrid = File.basename(file, ".json")

  group = ycrid[0..3]

  map_file = "var/yousuu/yscrits/#{group}-ztext.tsv"
  map = load_map(map_file)

  if ztext = map[ycrid]?
    next unless ztext.empty?
    count += 1
    puts "- recover: [#{ynvid}/#{ycrid}]".colorize.green
  else
    fresh += 1
    File.open("var/yousuu/fresh-yscrits.txt", "a", &.puts(file))
    puts "- fresh: [#{ynvid}/#{ycrid}]".colorize.blue
  end

  data = Data.from_json File.read(file)
  ztext = data.ztext
  # puts ztext
  # gets

  File.open(map_file, "a") do |io|
    io << '\n' << ycrid << '\t'
    ztext.join(io, '\t')
  end
end

puts "- recover: #{count}, fresh: #{fresh}"
