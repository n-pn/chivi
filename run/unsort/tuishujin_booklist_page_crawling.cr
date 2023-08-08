require "http/client"

def still_fresh?(fpath : String, stale : Time)
  File.info?(fpath).try(&.modification_time.> stale) || false
end

def get_page(flink : String, fpath : String) : Nil
  HTTP::Client.get(flink) do |res|
    File.write(fpath, res.body_io.gets_to_end)
  end
end

URL = "https://pre-api.tuishujun.com/api/listBooklist/v1?type=most_new"
DIR = "var/zroot/.keep/tuishu/listBooklist"
Dir.mkdir_p(DIR)

page_total = 35253
page_limit = 50

page_count = page_total // page_limit + 1

stale = Time.utc - 24.hours

pages = (1..page_count).to_a
pages.shuffle! if ARGV.includes?("--rand")

pages.each do |page|
  fpath = "#{DIR}/#{page}-#{page_limit}.json"

  if still_fresh?(fpath, stale: stale)
    puts "- <#{page}/#{page_count}> [#{fpath}] still fresh, skipping"
  else
    flink = "#{URL}&page=#{page}&pageSize=#{page_limit}"
    get_page(flink, fpath)
    puts "- <#{page}/#{page_count}> saved [#{flink}] to [#{fpath}]"
  end
end
