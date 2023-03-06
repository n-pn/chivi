require "zstd"
require "colorize"

require "../_raw/raw_ys_crit"

INP    = "var/ysraw/crits-by-user"
HIDDEN = "请登录查看评论内容"

TXT_DIR = "var/ysapp/crits-txt"
TMP_DIR = "var/ysapp/crits-idx"

def read_file(inp_path : String)
  file = File.open(inp_path, "r")
  json = Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)

  if json == "请稍后访问"
    File.delete(inp_path)
    File.open("#{TMP_DIR}/error-pages.txt", "a", &.puts(inp_path))
    {[] of YS::RawYsCrit, 0}
  else
    data = YS::RawBookComments.from_json(json)
    {data.comments, data.total}
  end
end

files = Dir.glob("#{INP}/**/*.json.zst")
puts files.size

totals = {} of Int32 => Int32

files.each do |path|
  puts path.colorize.cyan

  unless user_id = File.basename(path).split('.').first.to_i?
    File.delete(path)
    File.open("#{TMP_DIR}/error-pages.txt", "a", &.puts(path))
    next
  end

  crits, total = read_file(path)

  old_total = totals[user_id]? || 0

  if total > old_total
    totals[user_id] = total
    File.open("#{TMP_DIR}/totals.tsv", "a", &.puts("#{user_id}\t#{total}"))
  end

  crits.each do |crit|
    next if crit.ztext == HIDDEN || crit.ztext.blank?

    group = crit.y_cid[0..3]
    out_dir = "#{TXT_DIR}/#{group}-zh"

    Dir.mkdir_p(out_dir)
    File.write("#{out_dir}/#{crit.y_cid}.txt", crit.ztext)

    File.open("#{TMP_DIR}/#{group}-body.tsv", "a") do |io|
      io.puts("#{crit.y_cid}\t#{crit.ztext.size}")
    end
  end
rescue ex
  puts path.colorize.red
  puts ex.inspect_with_backtrace
end
