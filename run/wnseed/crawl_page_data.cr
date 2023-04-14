require "option_parser"
require "../../src/wnapp/util/dl_host"

hostname = "www.uukanshu.com"
from_bid = 1
upto_bid = 0
conn_num = 8

OptionParser.parse(ARGV) do |parser|
  parser.on("-h HOST", "hostname") { |h| hostname = h }
  parser.on("-u UPTO", "max book id") { |u| upto_bid = u.to_i }
  parser.on("-f FROM", "min book id") { |f| from_bid = f.to_i }
  parser.on("-c CONN", "concurrency") { |c| conn_num = c.to_i }
end

Log.setup_from_env

dlhost = DlHost.load_by_name(hostname) { exit 1 }
out_dir = "var/books/.html/#{dlhost.hostname}"
Dir.mkdir_p(out_dir)

if upto_bid < from_bid
  upto_bid = dlhost.get_last_bid.try(&.to_i) || raise "can't find latest book id"
  puts "Auto guess latest book id: #{upto_bid.colorize.yellow}"
end

puts "Crawling #{hostname} from #{from_bid} to #{upto_bid}"

inputs = [] of {String, String}

upto_bid.to(from_bid) do |bid|
  inputs << {"#{out_dir}/#{bid}.htm.zst", dlhost.get_book_path(bid)}
end

q_size = inputs.size

workers = Channel({String, String, Int32}).new(q_size)
results = Channel(Nil).new(conn_num)

conn_num.times do
  spawn do
    loop do
      out_path, uri_path, idx = workers.receive

      unless File.exists?(out_path)
        html = dlhost.fetch_html(uri_path)
        dlhost.save_zst(out_path, html) unless html.empty?

        puts "- #{idx}/#{q_size}  #{uri_path.colorize.blue} => [#{out_path}]"
      end
    rescue err
      Log.error(exception: err) { err.message.colorize.red }
    ensure
      results.send(nil)
    end
  end
end

inputs.each_with_index(1) { |(path, href), idx| workers.send({path, href, idx}) }
q_size.times { results.receive }
