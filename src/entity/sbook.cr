# Book entity for scrapping
require "json"

class SBook
  include JSON::Serializable

  property bsid : String = ""

  property title : String = ""
  property author : String = ""
  property intro : String = ""

  property cover : String = ""
  property genre : String = ""
  property tags : Array(String) = [] of String

  property status : Int32 = 0

  # property word_count : Int32 = 0
  property chap_count : Int32 = 0
  property updated_at : Int64 = 0

  def initialize(@bsid, @updated_at = 0_i64)
  end

  def label
    "#{@title}--#{@author}"
  end

  def to_s(io : IO)
    io << to_pretty_json
  end

  def status=(status : String)
    case status
    when "完成", "完本", "已经完结", "已经完本", "完结"
      @status = 1
    else
      @status = 0
    end
  end

  def title=(title : String)
    @title = title.sub(/\(.+\)$/, "")
  end

  def author=(author : String)
    @author = author.sub(/\(.+\)$/, "").sub(/\t.*$/, "")
  end

  def genre=(genre : String)
    @genre = genre.sub("小说", "")
  end

  def updated_at=(time : String)
    @updated_at = SBook.parse_time(time)
  end

  LOCATION = Time::Location.fixed(3600 * 8)
  FORMATER = {"%F %T", "%F %R", "%F", "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T"}

  def self.parse_time(input : String)
    FORMATER.each do |format|
      return Time.parse(input, format, LOCATION).to_unix_ms
    rescue
      next
    end

    puts "Error parsing [#{input}]: unknown time format!".colorize(:red)
    Time.local(2010, 1, 1).to_unix_ms
  end
end
