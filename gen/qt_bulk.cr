require "compress/zip"
require "../src/mt_v1/core/m1_core"

def extract_zip(sname, sn_id, fname)
  zip_path = "/2tb/zroot/ztext/#{sname}/#{sn_id}.zip"
  out_path = "/2tb/qtran/#{fname}-#{sname}-#{sn_id}"

  Dir.mkdir_p(out_path)

  Compress::Zip::File.open(zip_path) do |zip|
    input = zip.entries.map do |entry|
      ch_no = File.basename(entry.filename, ".zh").to_i
      {ch_no, entry}
    end

    input.sort_by!(&.[0])
    count = 0

    input.each do |ch_no, entry|
      raw_data = entry.open(&.gets_to_end)
      count += raw_data.size

      if raw_data.starts_with?("///")
        lines = raw_data.lines
        chdiv = lines.shift.lstrip('/').strip
        raw_data = lines.join('\n')
        raw_data = "［#{chdiv}］#{raw_data}" unless chdiv.empty? || chdiv == "正文"
      end

      File.write("#{out_path}/#{ch_no // 10}.raw.txt", raw_data)
    end

    size = count // 100000 * 100000
    puts "#{fname}: #{size}"

    {out_path, size}
  end
end

def call_qt(inp_dir, wndic = "combine")
  wn_id = wndic.starts_with?("wn") ? wndic[2..].to_i : 0
  engine = M1::MtCore.init(wn_id)

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
  {"@Kak31", 1626, "ma-mon-yeu-nu", "qt_v1", "wn123863"},
]

output = inputs.map do |sname, sn_id, fname, mtype, margs|
  out_path, count = extract_zip(sname, sn_id, fname)
  {out_path, count, mtype, margs}
end

puts "size: #{output.sum(&.[1])}"

output.each do |out_path, _, _, margs|
  call_qt(out_path, margs)
end
