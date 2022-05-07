require "../../src/libcv/tl_util"
require "../../src/libcv/mt_core"

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

def translate(key : String, tag : String = "nr")
  CV::TlUtil.translate(key, tag)
end

common = Set(String).new File.read_lines("var/vpdicts/suggest.txt")

INP = "_db/vpinit/qtrans/outerqt"
dict = read_dict("#{INP}/mixed.txt")
puts "- input: #{dict.size} entries"

dict.reject! do |k, v|
  next true unless common.includes?(k)
  next true if k =~ /嬷嬷|经理|妈妈|书记|姨妈|大妈|厂长|县长|乡长|状元|县令|将军|处长|元帅/

  v.reject!(&.=~ /{/)
  next true if v.empty?

  v.first.in? translate(k, "nr"), translate(k, "nn"), translate(k, "nz")
end

write_dict("#{INP}/mixed-common.txt", dict)
pp translate("复旦大学")
