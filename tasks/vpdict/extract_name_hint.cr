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

def translate(key : String, tag : String = "Nr")
  CV::TlUtil.translate(key, tag)
end

def fix_hanviet(dict)
  dict.each do |k, v|
    case k
    # when .includes?("鲍") then v.map!(&.gsub("Bảo", "Bào"))
    # when .includes?("佟") then v.map!(&.gsub("Đông", "Đồng"))
    # when .includes?("吕") then v.map!(&.gsub("Lữ", "Lã"))
    # when .includes?("宁") then v.map!(&.gsub("Trữ", "Ninh"))
    # when .includes?("卢") then v.map!(&.gsub("Lô", "Lư"))
    # when .includes?("肖") then v.map!(&.gsub("Tiếu", "Tiêu"))
    # when .includes?("邱") then v.map!(&.gsub("Khâu", "Khưu"))
    # when .includes?("武") then v.map!(&.gsub("Vũ", "Võ"))
    # when .includes?("候") then v.map!(&.gsub("Hầu", "Hậu"))
    # when .includes?("姬") then v.map!(&.gsub("Cừu", "Cơ"))
    # when .includes?("戴") then v.map!(&.gsub("Đới", "Đái"))
    # when .includes?("璇") then v.map!(&.gsub("Tuyền", "Toàn"))
    # when .includes?("场") then v.map!(&.gsub("Tràng", "Trường").gsub("tràng", "trường"))
    # when .includes?("蒋") then v.map!(&.gsub("Tương", "Tưởng"))
    # when .includes?("尹") then v.map!(&.gsub("Duẫn", "Doãn"))
    # when .includes?("实") then v.map!(&.gsub("Thật", "Thực"))
    # when .includes?("沃") then v.map!(&.gsub("Ôc", "Ốc"))
    # when .includes?("生") then v.map!(&.gsub("Sanh", "Sinh"))
    # when .includes?("冲") then v.map!(&.gsub("Trùng", "Xung"))
    # when .includes?("妮") then v.map!(&.gsub("Ny", "Ni"))
    # when .includes?("霸") then v.map!(&.gsub("Phách", "Bá").gsub("phách", "bá"))
    # when .includes?("聂") then v.map!(&.gsub("Niếp", "Nhiếp").gsub("niếp", "nhiếp"))
    # when .includes?("菲") then v.map!(&.gsub("Phỉ", "Phi"))
    # when .includes?("艾") then v.map!(&.gsub("Ngả", "Ngải").gsub("Ngảii", "Ngải"))
    # when .includes?("夭") then v.map!(&.gsub("Yêu", "Yểu"))
    # when .includes?("延") then v.map!(&.gsub("Duyên", "Diên"))
    # when .includes?("机") then v.map!(&.gsub("Ky", "Cơ"))
    # when .includes?("号") then v.map!(&.gsub("Hào", "Hiệu"))
    # when .includes?("蕃") then v.map!(&.gsub("Phiên", "Phồn"))
    # when .includes?("楷") then v.map!(&.gsub("Giai", "Khải"))
    # when .includes?("姆") then v.map!(&.gsub("Mỗ", "Mẫu"))
    # when .includes?("禅") then v.map!(&.gsub("Thiện", "Thiền"))
    # when .includes?("琪") then v.map!(&.gsub("Kì", "Kỳ"))
    # when .includes?("畏") then v.map!(&.gsub("Úy", "Uý"))
    # when .includes?("佑") then v.map!(&.gsub("Hữu", "Hựu"))
    # when .includes?("帅") then v.map!(&.gsub("Suất", "Soái").gsub("suất", "soái"))
    # when .includes?("夭") then v.map!(&.gsub("Yêu", "Yểu").gsub("Thiên", "Yểu"))
    # when .includes?("枭") then v.map!(&.gsub("Kiêu", "Hiêu"))
    # when .includes?("李") then v.map!(&.gsub("Lí", "Lý"))
    # when .includes?("滢") then v.map!(&.gsub("Oánh", "Huỳnh"))
    # when .includes?("综") then v.map!(&.gsub("Tống", "Tổng"))
    # when .includes?("庸") then v.map!(&.gsub("Dong", "Dung"))
    # when .includes?("螭") then v.map!(&.gsub("Ly", "Li"))
    # when .includes?("遥") then v.map!(&.gsub("Diêu", "Dao"))
    # when .includes?("幕") then v.map!(&.gsub("Mộ", "Mạc"))
    when .includes?("樊") then v.map!(&.gsub("Phiền", "Phàn"))
    when .includes?("筱") then v.map!(&.gsub("Tiểu", "Tiêu"))
    end

    v = v.uniq! # .reject!(&.empty?)

    if v.empty?
      dict.delete(k)
    else
      dict[k] = v
    end
  end

  write_dict("#{INP}/tmp/combined.txt", dict)
end

def checked?(k : String, v : String)
  {"菩薩", "群岛"}.each { |x| return true if k.ends_with?(x) }
  {"chòm sao", "đảo"}.each { |y| return true if v.starts_with?(y) }

  false
end

def extract_cases(input : Dict, prefix = "")
  upper = Dict.new
  lower = Dict.new
  mixed = Dict.new

  input.each do |k, v|
    hv = hanviet(k)
    hv_a = {
      hv,
      TextUtil.titleize(hv),
      translate(k, "Na"),
      translate(k, "Nr"),
      translate(k, "Nz"),
    }

    vf = v.first
    next if vf.in?(hv_a)

    v.reject!(&.in?(hv_a))

    if vf == vf.downcase
      lower[k] = v
    elsif vf == TextUtil.titleize(vf)
      upper[k] = v
    else
      mixed[k] = v # unless checked?(k, vf)
    end
  end

  write_dict("#{INP}/#{prefix}-lower.txt", lower)
  write_dict("#{INP}/#{prefix}-upper.txt", upper)
  write_dict("#{INP}/#{prefix}-mixed.txt", mixed)
end

INP = "_db/vpinit/qtrans/outerqt"
LAC = "_db/vpinit/bd_lac/out"
dict = read_dict("#{INP}/tmp/combined.txt")
fix_hanviet(dict)
# extract_cases(dict)

names = Set(String).new
names.concat File.read_lines("#{LAC}/book-names.txt")
names.concat File.read_lines("#{LAC}/top25/ondict-names.tsv").map(&.split('\t').first)
names.concat File.read_lines("#{LAC}/top25/unseen-names.tsv").map(&.split('\t').first)

File.open("#{INP}/book-names.txt", "w") do |io|
  names.each do |key|
    next unless vals = dict[key]?
    io.puts "#{key}=#{vals.join('/')}"
  end
end

extract_cases(read_dict("#{INP}/book-names.txt"), "names/names")
