FIX_HV = {
  '鲍' => [{"Bảo", "Bào"}],
  '佟' => [{"Đông", "Đồng"}],
  '吕' => [{"Lữ", "Lã"}],
  '呂' => [{"Lữ", "Lã"}],
  '宁' => [{"Trữ", "Ninh"}],
  '卢' => [{"Lô", "Lư"}],
  '肖' => [{"Tiếu", "Tiêu"}],
  '邱' => [{"Khâu", "Khưu"}],
  '武' => [{"Vũ", "Võ"}],
  '候' => [{"Hầu", "Hậu"}],
  '姬' => [{"Cừu", "Cơ"}],
  '戴' => [{"Đới", "Đái"}],
  '璇' => [{"Tuyền", "Toàn"}],
  '场' => [{"Tràng", "Trường"}],
  '蒋' => [{"Tương", "Tưởng"}],
  '尹' => [{"Duẫn", "Doãn"}],
  '实' => [{"Thật", "Thực"}],
  '沃' => [{"Ôc", "Ốc"}],
  '生' => [{"Sanh", "Sinh"}],
  '冲' => [{"Trùng", "Xung"}],
  '妮' => [{"Ny", "Ni"}],
  '霸' => [{"Phách", "Bá"}],
  '聂' => [{"Niếp", "Nhiếp"}],
  '菲' => [{"Phỉ", "Phi"}],
  '艾' => [{"Ngả", "Ngải"}, {"Ngảii", "Ngải"}],
  '延' => [{"Duyên", "Diên"}],
  '机' => [{"Ky", "Cơ"}],
  '号' => [{"Hào", "Hiệu"}],
  '蕃' => [{"Phiên", "Phồn"}],
  '楷' => [{"Giai", "Khải"}],
  '姆' => [{"Mỗ", "Mẫu"}],
  '禅' => [{"Thiện", "Thiền"}],
  '琪' => [{"Kì", "Kỳ"}],
  '畏' => [{"Úy", "Uý"}],
  '佑' => [{"Hữu", "Hựu"}],
  '帅' => [{"Suất", "Soái"}],
  '夭' => [{"Yêu", "Yểu"}, {"Thiên", "Yểu"}],
  '枭' => [{"Kiêu", "Hiêu"}],
  '李' => [{"Lí", "Lý"}],
  '滢' => [{"Oánh", "Huỳnh"}],
  '综' => [{"Tống", "Tổng"}],
  '庸' => [{"Dong", "Dung"}],
  '螭' => [{"Ly", "Li"}],
  '遥' => [{"Diêu", "Dao"}],
  '幕' => [{"Mộ", "Mạc"}],
  '樊' => [{"Phiền", "Phàn"}],
  '筱' => [{"Tiểu", "Tiêu"}],
}

FIX_HV.each_value do |vals|
  vals_2 = [] of {String, String}
  vals.each do |_old, _new|
    vals_2 << {_old.downcase, _new.downcase}
  end

  vals.concat(vals_2)
end

HV_RE = Regex.new(FIX_HV.keys.join('|'))

def fix_hanviet(key, val)
  key.scan(HV_RE).each do |match|
    char = match[0][0]

    FIX_HV[char].each do |old_hv, new_hv|
      val = val.gsub(old_hv, new_hv)
    end
  end

  val
end

output = {} of String => Array(String)

DIR = "var/inits/vietphrase"

File.each_line("#{DIR}/combined.txt") do |line|
  vals = line.split('\t')
  next if vals.size < 2

  key = vals.shift
  output[key] = vals.map { |v| fix_hanviet(key, v) }.uniq!
end

puncts = File.open("#{DIR}/combine-puncts.tsv", "w")
numbers = File.open("#{DIR}/combine-numbers.tsv", "w")
propers = File.open("#{DIR}/combine-propers.tsv", "w")

output.each do |key, vals|
  line = String.build { |io| io << key; vals.each { |v| io << '\t' << v }; io << '\n' }
  case key
  when /\p{P}/
    puncts << line
  when /\d/, /^第?[\d零〇一二两三四五六七八九十百千万亿 ]+[多章余]?$/
    numbers << line
  else
    propers << line
  end
end

puncts.close
numbers.close
propers.close

# File.open("#{DIR}/combine-cleaned.tsv", "w") do |file|
#   output.each do |key, vals|
#     file << key << '\t'
#     vals.join(file, '\t')
#     file << '\n'
#   end
# end

# output = {} of String => Set(String)
