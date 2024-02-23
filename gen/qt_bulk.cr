require "sqlite3"
require "../src/mt_v1/core/m1_core"

def extract_txt(sname, sn_id, fname)
  db3_path = "/2tb/zroot/wn_db/#{sname}/#{sn_id}-zdata.v1.db3"
  out_path = "/2tb/qtran/#{fname}-#{sname}-#{sn_id}"

  Dir.mkdir_p(out_path)
  count = 0

  DB.open("sqlite3:#{db3_path}?immutable=1") do |db|
    db.query_each "select ch_no, ztext, chdiv from czdata order by ch_no asc" do |rs|
      ch_no, ztext, chdiv = rs.read(Int32, String, String)
      count += ztext.size
      ztext = "［#{chdiv}］#{ztext}" unless chdiv.empty? || chdiv == "正文"
      File.write("#{out_path}/#{ch_no}.raw.txt", ztext)
    end
  end

  size = count // 100000 * 100000
  puts "#{fname}: #{size}"

  {out_path, size}
end

def call_qt(inp_dir, wndic = "combine")
  wn_id = wndic.starts_with?("wn") ? wndic[2..].to_i : 0
  engine = M1::MtCore.new(wn_id)

  output = [] of String
  inputs = Dir.glob(inp_dir + "/*.raw.txt")

  inputs.sort_by! do |file|
    File.basename(file, ".raw.txt").to_i
  end

  inputs.each_with_index do |inp_file, idx|
    puts "#{idx}: #{inp_file}"
    tmp_path = inp_file.sub(".raw", ".qt_v1")

    if File.file?(tmp_path)
      output << File.read(tmp_path)
    else
      File.open(tmp_path, "w") do |file|
        title = true
        File.each_line(inp_file) do |line|
          next if line.empty?

          data = title ? engine.cv_chead(line) : engine.cv_plain(line)
          data.to_txt(file)

          file.puts if title
          file.puts

          title = false
        end
      end

      sleep 500.millisecond
    end

    output << File.read(tmp_path)
  end

  out_path = "#{inp_dir}.qt_v1.txt"
  File.write(out_path, output.join("\n\n"))
  puts "#{out_path} saved!"
end

# total += export "@Kak31", 337, "the-tu-ngan-hung", "wn47172"
# total += export "@Numeron", 1333, "dai-phung-da-canh-nhan", "wn45646"
# total += export "@Kak31", 1306, "ta-khong-nghi-cung-nguoi-cung-noi-trung-sinh", "wn124931"
# total += export "@Kak31", 1443, "cu-tinh-dao-si", "wn35228"
# total += export "@Kak31", 899, "diep-vu-dai-duong-xuan", "wn54612"

inputs = [
  # {"@Kak31", 878, "hua-tien-chi", "qt_v1", "wn350"},
  # {"@Kak31", 886, "ma-hon-khai-lam", "qt_v1", "wn5344"},
  # {"@Kak31", 143, "ngu-lac-xuan-thu", "qt_v1", "wn26017"},
  # {"@Numeron", 1234, "thau-huong-cao-thu", "qt_v1", "wn7567"},
  # {"@Kak31", 659, "ngoc-dich-bach-ma", "qt_v1", "wn106581"},
  # {"@Kak31", 805, "huyen-mi-kiem", "qt_v1", "wn110743"},
  # {"@Numeron", 1314, "nga-gia-nuong-tu-bat-thi-yeu", "qt_v1", "wn1314"},
  # {"@Kak31", 1626, "ma-mon-yeu-nu", "qt_v1", "wn123863"},
  {"@Nipin", 1641, "tuyet-the-vo-song", "qt_v1", "wn15542"},
]

output = inputs.map do |sname, sn_id, fname, mtype, margs|
  out_path, count = extract_txt(sname, sn_id, fname)
  {out_path, count, mtype, margs}
end

puts "size: #{output.sum(&.[1])}"

output.each do |out_path, _, _, margs|
  call_qt(out_path, margs)
end
