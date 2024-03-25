require "../../src/_util/http_util"

URL = "https://pre-api.tuishujun.com/api/listBookRepository"
DIR = "/srv/chivi/.keep/tuishu/listBookRepository-#{Time.local.to_s("%F")}"
Dir.mkdir_p(DIR)

page_total = 388745
page_limit = 100

page_count = page_total // page_limit + 1

pages = (1..page_count).to_a
pages.shuffle! if ARGV.includes?("--rand")

pages.each do |page|
  fpath = "#{DIR}/#{page}-#{page_limit}.json"

  if File.file?(fpath)
    Log.info { "<#{page}/#{page_count}> [#{fpath}] still fresh, skipping" }
  else
    flink = "#{URL}?page=#{page}&pageSize=#{page_limit}"
    File.write(fpath, HttpUtil.fetch(flink, encoding: "UTF-8"))
    Log.info { "<#{page}/#{page_count}> saved [#{flink}] to [#{fpath}]".colorize.green }
  end
end
