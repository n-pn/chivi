require "json"

class Spider::Serial
  DIR = "data/txt-tmp/serials"

  def self.load!(site : String, bsid : String)
    load!(file_path(site, bsid))
  end

  def self.load!(file : String)
    from_json(File.read(file))
  end

  def self.file_path(site : String, bsid : String)
    File.join(DIR, site, "#{bsid}.json")
  end

  include JSON::Serializable

  property site = ""
  property bsid = ""

  property title = ""
  property author = ""
  property intro = ""

  property genre = ""
  property tags = [] of String

  property cover = ""
  property status = 0
  property mtime = 0_i64

  def initialize(@site : String, @bsid : String, @mtime = 0_i64)
  end

  def to_s(io : IO)
    to_pretty_json(io)
  end

  def save!(file = Serial.file_path(@site, @bsid))
    File.write(file, to_json)
  end

  def label
    "#{@title}--#{@author}"
  end

  # def title=(title : String)
  #   @title = title.sub(/\(.+\)$/, "")
  # end

  # def author=(author : String)
  #   @author = author.sub(/\(.+\)$/, "").sub(/\t.*$/, "")
  # end

  def genre=(genre : String)
    @genre = genre.sub("小说", "")
  end

  def cover=(@cover : String)
    @cover = @cover.sub("qu.la", "jx.la") if @site == "jx_la"
  end

  def status=(status : String)
    case status
    when "完成", "完本", "已经完结", "已经完本", "完结"
      @status = 1
    else
      @status = 0
    end
  end

  def mtime=(time : String)
    mtime = parse_time(time)
    @mtime = mtime if mtime > @mtime
  end

  LOCATION = Time::Location.fixed(3600 * 8)
  FORMATS  = {"%F %T", "%F %R", "%F", "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T"}

  private def parse_time(input : String)
    FORMATS.each do |format|
      return Time.parse(input, format, LOCATION).to_unix_ms
    rescue
      next
    end

    puts "Error parsing <#{input}>: unknown time format!".colorize(:red)
    0_i64
  end
end
