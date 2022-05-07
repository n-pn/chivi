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

INP = "_db/vpinit/qtrans/outerqt"
dict = read_dict("#{INP}/tmp/combined.txt")

dict.each do |k, v|
  case k
  # when .includes?("鲍")
  #   v = v.map(&.sub("Bảo", "Bào"))
  # when .includes?("佟")
  #   v = v.map(&.sub("Đông", "Đồng"))
  # when .includes?("吕")
  #   v = v.map(&.sub("Lữ", "Lã"))
  # when .includes?("宁")
  #   v = v.map(&.sub("Trữ", "Ninh"))
  # when .includes?("卢")
  #   v = v.map(&.sub("Lô", "Lư"))
  # when .includes?("肖")
  # v = v.map(&.sub("Tiếu", "Tiêu"))
  # when .includes?("邱")
  # v = v.map(&.sub("Khâu", "Khưu"))
  # when .includes?("武")
  #   v = v.map(&.sub("Vũ", "Võ"))
  # when .includes?("候")
  # v = v.map(&.sub("Hầu", "Hậu"))
  # when .includes?("姬")
  #   v = v.map(&.sub("Cừu", "Cơ"))
  # when .includes?("戴")
  # v = v.map(&.sub("Đới", "Đái"))
  # when .includes?("璇")
  # v = v.map(&.sub("Tuyền", "Toàn"))
  # when .includes?("场")
  # v = v.map(&.sub("Tràng", "Trường").sub("tràng", "trường"))
  # when .includes?("蒋")
  # v = v.map(&.sub("Tương", "Tưởng"))
  when .includes?("尹")
    v = v.map(&.sub("Duẫn", "Doãn"))
  end

  v = v.uniq!.reject!(&.empty?)
  if v.empty?
    dict.delete(k)
  else
    dict[k] = v
  end
end

write_dict("#{INP}/tmp/combined.txt", dict)

upper = Dict.new
lower = Dict.new
mixed = Dict.new

dict.each do |k, v|
  hv = hanviet(k)
  hvs = {hv, CV::TextUtil.titleize(hv), translate(k, "nn"), translate(k, "nr")}

  if v.first.in?(hvs)
    next if v.size == 1 || v[1].in?(hvs)
  end

  fv = v.first
  if fv == fv.downcase
    lower[k] = v
  elsif fv == CV::TextUtil.titleize(fv)
    upper[k] = v
  else
    mixed[k] = v
  end
end

write_dict("#{INP}/lower.txt", lower)
write_dict("#{INP}/upper.txt", upper)
write_dict("#{INP}/mixed.txt", mixed)

# dict.reject! do |k, v|
#   v.first.in? CV::TlUtil.translate(k, "nr"), CV::TlUtil.translate(k, "nn")
# end

# puts "- cleaned: #{dict.size} entries"
# write_dict("#{INP}/ptitles.txt", dict)
