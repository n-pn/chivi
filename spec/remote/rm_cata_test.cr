require "json"
require "../../src/wnapp/remote/rm_cata.cr"
require "../../src/_util/site_link"

def fetch_info(sname, s_bid, fresh = false) : Void
  link = SiteLink.mulu_url(sname, s_bid)
  puts "\n[#{link}]".colorize.green.bold

  parser = WN::RmCata.new(link, ttl: fresh ? 10.seconds : 10.years)
  parser.parse!

  puts "------".colorize.green

  puts "chap_count: #{parser.chaps.size}"
  puts "last_s_cid: #{parser.last_s_cid}"
  puts "------".colorize.green

  parser.chaps.first(4).map { |x| puts x }
  puts "------".colorize.green

  parser.chaps.last(4).map { |x| puts x }
  puts "------".colorize.green
rescue err
  puts err.colorize.red
end

tests = [
  {"69shu", 35875, false},
  {"hetushu", 5, false},

  {"xbiquge", 48680, false},
  {"paoshu8", 817, false},
  {"biqu5200", 131878, false},

  {"uukanshu", 33933, false},

  {"b5200", 160872, false},
  {"bxwxio", 127400, false},

  {"133txt", 9, false},

  {"uuks", 56862, false},

  {"69shu", 41121, false},
]

tests.each do |sname, s_bid, fresh|
  fetch_info(sname, s_bid, fresh: fresh)
end
