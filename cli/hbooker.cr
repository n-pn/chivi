require "openssl"
require "base64"
require "json"
require "log"
require "colorize"

struct ChapInfo
  include JSON::Serializable

  getter chapter_id : String
  getter chapter_index : String
  getter chapter_title : String

  getter word_count : String
  getter mtime : String
end

struct ChapList
  include JSON::Serializable

  # volumn
  getter division_id : String
  getter division_index : String
  getter division_name : String

  getter max_update_time : Int64
  getter max_chapter_index : Int32

  getter chapter_list : Array(ChapInfo)
end

struct ChapText
  include JSON::Serializable

  getter book_id : String
  getter division_id : String

  getter chapter_id : String
  getter chapter_index : String
  getter chapter_title : String

  getter author_say : String
  getter word_count : String

  getter ctime : String
  getter mtime : String

  getter txt_content : String
end

alias ListData = NamedTuple(data: NamedTuple(chapter_list: Array(ChapList)))
alias TextData = NamedTuple(data: NamedTuple(chapter_info: ChapText))

def parse_list(json : String)
  data = ListData.from_json(json)
  data[:data][:chapter_list]
end

def parse_text(json : String)
  data = TextData.from_json(json)
  data[:data][:chapter_info]
end

CYPHER_KEY = Base64.decode "lXsAUe1NZEw6tAxM9w1Tpq2tU4la2+PwM8evj2C+yB0="
CYPHER_IV  = Base64.decode "AAAAAAAAAAAAAAAAAAAAAA=="

def decrypt(input : String)
  cipher = OpenSSL::Cipher.new("aes-256-cbc")
  cipher.decrypt

  cipher.key = CYPHER_KEY
  cipher.iv = CYPHER_IV

  io = IO::Memory.new
  data = Base64.decode(input)
  io.write(cipher.update(data))
  io.write(cipher.final)
  io.rewind

  io.gets_to_end
end

API_ROOT = "https://app.hbooker.com"

ACCOUNT     = ENV.fetch("ACC", "书客1892757")
LOGIN_TOKEN = ENV.fetch("TOKEN", "5398f1fb53f767fd1691a1031dba03f4")

def info_url(book_id : String | Int32)
  "#{API_ROOT}/book/get_info_by_id?book_id=#{book_id}&app_version=2.9.022&device_token=ciweimao_&login_token=#{LOGIN_TOKEN}&account=#{ACCOUNT}"
end

def repo_url(book_id : String | Int32)
  "#{API_ROOT}/chapter/get_updated_chapter_by_division_new?book_id=#{book_id}&app_version=2.9.022&device_token=ciweimao_&login_token=#{LOGIN_TOKEN}&account=#{ACCOUNT}"
end

def ctext_url(chap_id : String | Int32)
  "#{API_ROOT}/chapter/get_chapter_info?chapter_id=#{chap_id}&app_version=2.9.022&device_token=ciweimao_&login_token=#{LOGIN_TOKEN}&account=#{ACCOUNT}"
end

def get_chap(chap_id : Int32)
  HTTP::Client.get(ctext_url(chap_id)) do |res|
    json = decrypt(res.body_io.gets_to_end)
    puts json
  end
end

PROXY = ENV["PROXY"]?

def fetch_chap(chap_id : Int32, save_path : String)
  curl_cmd = "curl '#{ctext_url(chap_id)}' -fsL --compressed -H 'Accept-Encoding: gzip, deflate, br'"
  curl_cmd += " -x #{PROXY}" if PROXY

  html = `#{curl_cmd}`
  if html.blank?
    Log.info { chap_id.colorize.red }
  else
    File.write(save_path, html)
  end
end

def crawl_all(from, upto, wsize)
  queue = (from..upto).to_a
  qsize = queue.size

  workers = Channel(Int32).new(qsize)
  results = Channel(Int32).new(wsize)

  inp_dir = "/srv/chivi/crawl/ciweimao/chapters"
  Dir.mkdir_p(inp_dir)

  spawn do
    queue.each { |chap_id| workers.send(chap_id) }
  end

  wsize.times do
    spawn do
      loop do
        chap_id = workers.receive
        save_path = "#{inp_dir}/#{chap_id}.tmp"
        fetch_chap(chap_id, save_path) unless File.file?(save_path)
        results.send(chap_id)
      rescue ex
        Log.info { ex }
        results.send(0)
      end
    end
  end

  puts "input: #{qsize}, workers: #{wsize}"
  qsize.times { Log.info { results.receive.colorize.green } }
end

from = ARGV[0]?.try(&.to_i) || 100001252
upto = ARGV[1]?.try(&.to_i) || 111490167
wsize = ENV["WSIZE"]?.try(&.to_i?) || 32

crawl_all(from, upto, wsize)

# puts decrypt(fetch_chap(10200152))
