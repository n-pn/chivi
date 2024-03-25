require "../../src/_util/http_util"

URL = "https://pre-api.tuishujun.com/api/listBooklist/v1?type=most_new"

DIR = "/srv/chivi/.keep/tuishu/listBooklist-#{Time.local.to_s("%F")}"
Dir.mkdir_p(DIR)

page_total = 38184
page_limit = 50

page_count = page_total // page_limit + 1

stale = Time.utc - 24.hours

pages = (1..page_count).to_a
pages.shuffle! if ARGV.includes?("--rand")

pages.each do |page|
  fpath = "#{DIR}/#{page}-#{page_limit}.json"

  if File.file?(fpath)
    Log.info { "<#{page}/#{page_count}> [#{fpath}] existed, skipping" }
  else
    flink = "#{URL}&page=#{page}&pageSize=#{page_limit}"
    File.write(fpath, HttpUtil.fetch(flink, encoding: "UTF-8", use_proxy: false))
    Log.info { "<#{page}/#{page_count}> [#{fpath}] saved".colorize.green }
  end
end
