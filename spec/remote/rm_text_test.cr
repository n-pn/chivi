require "colorize"

require "../../src/wnapp/remote/rm_text.cr"
require "../../src/_util/site_link"

def fetch_text(sname : String, s_bid : Int32, s_cid : Int32, reset = false)
  link = SiteLink.text_url(sname, s_bid, s_cid)
  fetch_text(link)
end

def fetch_text(link : String, reset = false)
  puts "\n[#{link.colorize.blue.bold}]"

  chap = WN::RmText.new(link, ttl: reset ? 10.seconds : 10.years)
  puts

  puts chap.bname.colorize.yellow
  puts "---".colorize.dark_gray
  puts chap.title.colorize.green
  puts "---".colorize.dark_gray
  puts chap.body.first(4).join("\n")
  puts "---".colorize.dark_gray
  puts chap.body.last(4).join("\n")
rescue err
  puts err.inspect_with_backtrace.colorize.red
end

fetch_text("http://www.kenshuzw.com/xiaoshuo/30192/16590117/", true)
