require "http/client"

def still_fresh?(path : String, expiry_date : Time)
  File.info?(path).try(&.modification_time.> expiry_date) || false
end

def get_page(link : String, save_path : String) : Nil
  HTTP::Client.get(link) do |res|
    File.write(save_path, res.body_io.gets_to_end)
  end
end

URL = "https://pre-api.tuishujun.com/api/listBookRepository"
DIR = "var/zroot/.keep/tuishu/listBookRepository"
Dir.mkdir_p(DIR)

page_total = 304297
page_limit = 100

page_count = page_total // page_limit + 1

expiry_date = Time.utc - 24.hours

pages = (1..page_count).to_a
pages.shuffle! if ARGV.includes?("--rand")

pages.each do |page|
  save_path = "#{DIR}/#{page}-#{page_limit}.json"

  if still_fresh?(save_path, expiry_date: expiry_date)
    puts "- <#{page}/#{page_count}> [#{save_path}] still fresh, skipping"
  else
    link = "#{URL}?page=#{page}&pageSize=#{page_limit}"
    get_page(link, save_path)
    puts "- <#{page}/#{page_count}> saved [#{link}] to [#{save_path}]"
  end
end
