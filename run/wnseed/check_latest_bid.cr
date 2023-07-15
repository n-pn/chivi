require "../../src/wnapp/util/dl_host"

hostname = ARGV[0]? || "xbiquge.bz"
dlhost = DlHost.load_by_name(hostname) { exit 1 }

last_bid = dlhost.get_last_bid.try(&.to_i) || raise "can't find latest book id"
puts "Latest book id for #{hostname.colorize.yellow}: #{last_bid.colorize.yellow}"
