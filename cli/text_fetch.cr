require "option_parser"

require "../src/_data/remote/remote_text"

Log.setup(:fatal)

sname = s_bid = s_cid = ""
force = false

OptionParser.parse do |parser|
  parser.on("-f", "redownload even if cached") { force = true }
  parser.unknown_args do |args|
    sname, s_bid, s_cid = args
  end
end

ttl = force ? 1.minutes : 10.years

remote = CV::RemoteText.new(sname, s_bid.to_i, s_cid.to_i, ttl: ttl)

title = remote.title
STDOUT.puts(title) unless title.empty?
remote.paras.each { |line| STDOUT.puts(line) }
