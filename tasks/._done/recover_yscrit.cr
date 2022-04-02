require "json"
require "tabkv"
require "colorize"

class Data
  include JSON::Serializable

  getter _id : String
  getter book_id : Int32
  getter poster_id : Int32
  getter poster_name : String
  getter rating : Int32
  getter content : String
  getter like_count : Int32
  getter reply_count : Int32

  RE = Regex.new("<br ?/?>")

  def ztext
    lines = content.sub(RE, "\n").split("\n")
    lines.map(&.strip).reject(&.empty?)
  end

  def utime
    time = _id[0..7].to_i(base: 16)
    Time.unix(time)
  end
end

OUT = "var/yscrits"

def save_missing(file : String) : Data
  json = Data.from_json File.read(file)
  group = json._id[0..3]
  ztext_map = Tabkv.new("#{OUT}/#{group}-ztext.tsv")
  ztext_map.set!(json._id, json.ztext)
  ztext_map.save!(dirty: false)

  json
end

def save_fresh(file : String)
  json = save_missing(file)
  group = json._id[0..3]
  utime = json.utime

  infos = [
    json.book_id, json.poster_id, json.poster_name,
    json.rating, json.like_count, json.reply_count,
    utime, utime,
  ]

  infos_map = Tabkv.new("#{OUT}/#{group}-infos.tsv")
  infos_map.set!(json._id, infos)
  infos_map.save!(dirty: false)
end

missing = Set(String).new File.read_lines("var/_yousuu/yscrits-missing.txt")
healthy = Set(String).new File.read_lines("var/_yousuu/yscrits-healthy.txt")

DIR = "_db/.keeps/yousuu/yscrits"
ybids = Dir.children(DIR)
count = fresh = 0

ybids.each do |ybid|
  files = Dir.glob("#{DIR}/#{ybid}/*.json")
  files.each do |file|
    ycrid = File.basename(file, ".json")
    if missing.includes?(ycrid)
      count += 1
      save_missing(file)
    elsif !healthy.includes?(ycrid)
      fresh += 1
      save_fresh(file)
    end
  rescue err
    puts file, err
  end
end

puts "- recover: #{count}, fresh: #{fresh}"
