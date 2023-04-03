require "zstd"
require "colorize"

require "../_raw/raw_ys_crit"

INP = "var/ysraw/crits-by-user"

TXT_DIR = "var/ysapp/crits-txt"
TMP_DIR = "var/ysapp/crits-idx"

def read_file(inp_path : String)
  file = File.open(inp_path, "r")
  json = Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)

  if json == "请稍后访问"
    File.delete(inp_path)
    nil
  else
    YS::RawBookComments.from_json(json).comments
  end
end

files = Dir.glob("#{INP}/**/*.json.zst")
puts files.size

files.each do |path|
  puts path.colorize.cyan
  next unless crits = read_file(path)

  crits.each do |crit|
    next if crit.ztext == "请登录查看评论内容" || crit.ztext.blank?

    out_dir = "#{TXT_DIR}/#{crit.yc_id[0..3]}-zh"
    Dir.mkdir_p(out_dir)

    File.write("#{out_dir}/#{crit.yc_id}.txt", crit.ztext)
  end
rescue ex
  puts path.colorize.red
  puts ex.inspect_with_backtrace
end
