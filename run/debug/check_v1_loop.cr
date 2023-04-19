require "colorize"
require "../../src/ysapp/_raw/raw_ysrepl"
require "../../src/mt_v1/core/m1_core"

MTL = M1::MtCore.init

DIR = "var/ysraw/repls"

Dir.children(DIR).each do |yc_id|
  files = Dir.glob("#{DIR}/#{yc_id}/*.json.zst")
  files.each do |file|
    try_file file
  end
end

# try_file "var/ysraw/repls/599c48afd7935daf3a95f4e2/1.51d7y2.json.zst"

def try_file(file : String)
  # puts file

  data = YS::RawCritReplies.from_json(read_zstd(file))
  data.repls.each do |repl|
    repl.ztext.each_line do |line|
      line = line.strip
      try_translate(line) unless line.empty?
    end
  end
end

def try_translate(line : String)
  puts line.colorize.blue
  puts MTL.cv_plain(line)
  # .to_txt.colorize.green
end
