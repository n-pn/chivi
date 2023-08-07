require "colorize"
require "option_parser"
require "../../zroot/rmbook"

def do_sync_file(out_db : DB::Database, sname : String, sn_id : Int32, fpath : String, force = false)
  loop do
    return false unless entry = ZR::Rmbook.from_html_file(fpath, sname: sname, sn_id: sn_id.to_s, force: force)
    entry.upsert!(out_db)
    return true
  rescue ex : SQLite3::Exception
    sleep 0.5
  rescue ex
    puts [ex, fpath].colorize.red
    return false
  end
end

seed = "!hetushu"

bmax = 0
bmin = 1
days = 30.days

force = false
cnn_mod = 1
cnn_rem = 0

OptionParser.parse(ARGV) do |parser|
  parser.on("-f", "force reseed") { force = true }
  parser.on("-s HOSTNAME", "source name") { |s| seed = s }
  parser.on("--mod CNN_MOD", "total connection") { |i| cnn_mod = i.to_i }
  parser.on("--rem CNN_REM", "connection index") { |i| cnn_rem = i.to_i }
  parser.on("--max BMAX_ID", "max book id") { |i| bmax = i.to_i }
  parser.on("--min BMIN_ID", "min book id") { |i| bmin = i.to_i }
  parser.on("--old TOO_OLD", "skips fresh") { |i| days = i.to_i.days }
end

rmconf = Rmconf.load!(seed)
out_db = ZR::Rmbook.db(rmconf.seedname)

if bmax < 1
  bmax = rmconf.get_max_bid(6.hours)
  puts "MAX_BOOK_ID: #{bmax.colorize.yellow}"
end

total = bmax - bmin + 1
index = 0

stale = Time.utc - days

cnn_mod = 1 if cnn_mod < 1
cnn_rem %= cnn_mod

Dir.mkdir_p "var/.keep/rmbook/#{rmconf.hostname}"

bmin.to(bmax) do |bid|
  index &+= 1
  next unless index % cnn_mod == cnn_rem

  file_path = rmconf.book_file_path(bid)

  unless Rmutil.still_fresh?(file_path, stale: stale)
    link_path = rmconf.make_book_path(bid)
    rmconf.save_page(link_path, file_path)
  end

  # sleep 3.seconds

  spawn do
    success = do_sync_file(out_db, sname: rmconf.seedname, sn_id: bid, fpath: file_path, force: force)

    if success
      puts "- <#{index.colorize.cyan}/#{total}> [#{seed.colorize.yellow}/#{bid.colorize.green}] saved."
    else
      puts "- <#{index.colorize.cyan}/#{total}> [#{seed.colorize.yellow}/#{bid.colorize.red}] skipped."
    end
  end
rescue err
  puts err
end
