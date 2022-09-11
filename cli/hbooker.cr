require "openssl"
require "base64"
require "json"

module Hbooker
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
    data = Base64.decdoe(input)
    io.write(cipher.update(data))
    io.write(cipher.final)
    io.rewind

    io.gets_to_end
  end

  API_ROOT = "https://app.hbooker.com"

  LOGIN_TOKEN = "72f3af0d35193d8268e00f8d0b4a9588"
  ACCOUNT     = "书客931494286477"

  def info_url(book_id : String)
    "#{API_ROOT}/book/get_info_by_id?book_id=#{book_id}&app_version=2.9.022&device_token=ciweimao_&login_token=#{LOGIN_TOKEN}&account=#{ACCOUNT}"
  end

  def list_url(book_id : String)
    "#{API_ROOT}/chapter/get_updated_chapter_by_division_new?book_id=#{book_id}&app_version=2.9.022&device_token=ciweimao_&login_token=#{LOGIN_TOKEN}&account=#{ACCOUNT}"
  end

  def chap_url(chap_id : String)
    "#{API_ROOT}/chapter/get_chapter_info?chapter_id=#{chap_id}&app_version=2.9.022&device_token=ciweimao_&login_token=#{LOGIN_TOKEN}&account=#{ACCOUNT}"
  end

  extend self
end
