require "../../src/mt_v2/tl_util"
require "../../src/mt_v2/mt_core"

alias Dict = Hash(String, Array(String))

def read_dict(file : String)
  File.read_lines(file).each_with_object(Dict.new) do |line, hash|
    key, val = line.split('=', 2)
    hash[key] = val.split('/')
  end.tap do |dict|
    puts "- loaded #{File.basename(file)}: #{dict.size} entries"
  end
end

def write_dict(file : String, dict : Dict)
  File.write(file, dict.map { |k, v| "#{k}=#{v.join('/')}" }.join('\n'))
  puts "- #{File.basename(file)} saved: #{dict.size} entries"
end

def hanviet(key : String, cap = false)
  CV::MtCore.cv_hanviet(key, cap)
end

INP = "_db/vpinit/qtrans/outerqt/names"
LAC = "_db/vpinit/bd_lac/out"

input = read_dict("#{INP}/names-upper.txt")

def has_hanviet?(key, val)
  words = val.split(" ")
  return false if words.size != key.size
  hanviets = hanviet(key, true).split(" ")
  !(words & hanviets).empty?
end

hanviet = Dict.new
western = Dict.new

input.each do |key, vals|
  if has_hanviet?(key, vals.first)
    hanviet[key] = vals
  else
    western[key] = vals
  end
end

write_dict("#{INP}/upper/names-upper-hanviet.txt", hanviet)
write_dict("#{INP}/upper/names-upper-western.txt", western)
