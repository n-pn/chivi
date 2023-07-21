require "colorize"
require "option_parser"
require "./shared/rmseed"

host = "www.hetushu.com"

bmax = 0
bmin = 1
days = 30.days

cnn_mod = 1
cnn_rem = 0

OptionParser.parse(ARGV) do |parser|
  parser.on("-s HOSTNAME", "source name") { |s| host = s }
  parser.on("--mod CNN_MOD", "total connection") { |i| cnn_mod = i.to_i }
  parser.on("--rem CNN_REM", "connection index") { |i| cnn_rem = i.to_i }
  parser.on("--max BMAX_ID", "max book id") { |i| bmax = i.to_i }
  parser.on("--min BMIN_ID", "min book id") { |i| bmin = i.to_i }
  parser.on("--old TOO_OLD", "skips fresh") { |i| days = i.to_i.days }
end

remote = Rmseed.new(host)

if bmax < 1
  bmax = remote.get_mbid.to_i
  puts "MAX_BOOK_ID: #{bmax.colorize.yellow}"
end

total = bmax - bmin + 1
index = 0

too_old = Time.utc - days

cnn_mod = 1 if cnn_mod < 1
cnn_rem %= cnn_mod

bmax.to(bmin) do |bid|
  index &+= 1
  next unless index % cnn_mod == cnn_rem

  file_path = remote.conf.book_file_path(bid)
  next if Rmutil.still_fresh?(file_path, too_old: too_old)

  sleep 3.seconds

  link_path = remote.conf.make_book_path(bid)
  remote.save_page(link_path, file_path)

  puts "- <#{index}/#{total}> [#{host}/#{bid.colorize.cyan}] saved."
rescue err
  puts err
end
