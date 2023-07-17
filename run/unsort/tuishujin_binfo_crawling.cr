require "http/client"

def still_fresh?(path : String, expiry_date : Time)
  File.info?(path).try(&.modification_time.> expiry_date) || false
end

def get_page(link : String, save_path : String) : Nil
  HTTP::Client.get(link) { |res| File.open(save_path, "wb") { |file| IO.copy(res.body_io, file) } }
end

URL = "https://pre-api.tuishujun.com/api/listBookRepository"
DIR = "/2tb/var.chivi/.keep/random/tuishujin/listBookRepositorypage"
Dir.mkdir_p(DIR)

page_total = 304285
page_limit = 200

page_count = page_total // page_limit + 1

expiry_date = Time.utc - 24.hours

1.upto(page_count) do |page|
  save_path = "#{DIR}/#{page}-#{page_limit}.json"

  if still_fresh?(save_path, expiry_date: expiry_date)
    puts "- <#{page}/#{page_count}> [#{save_path}] still fresh, skipping"
  else
    link = "#{URL}?page=#{page}&pageSize=#{page_limit}"
    get_page(link, save_path)
    puts "- <#{page}/#{page_count}> saved [#{link}] to [#{save_path}]"
  end
end
