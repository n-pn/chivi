# Book entity for scrapping
require "json"
require "./_util"

class SBook
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

  property chaps = 0
  property mtime = 0_i64

  def initialize(@site, @bsid, @mtime = 0_i64)
  end

  def label
    "#{@title}--#{@author}"
  end

  def to_s(io : IO)
    io << to_pretty_json
  end

  def save!
    save!(SBook.file_path(@site, @bsid))
  end

  def save!(file : String)
    File.write(file, to_json)
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
    mtime = SBook.parse_time(time)
    @mtime = mtime if mtime > @mtime
  end

  LOCATION = Time::Location.fixed(3600 * 8)
  FORMATS  = {"%F %T", "%F %R", "%F", "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T"}

  def self.parse_time(input : String)
    FORMATS.each do |format|
      return Time.parse(input, format, LOCATION).to_unix_ms
    rescue
      next
    end

    puts "Error parsing <#{input}>: unknown time format!".colorize(:red)
    0_i64
  end

  @@dir = "data/txt-tmp/serials"

  def self.dir
    @@dir
  end

  def self.chdir(dir : String)
    @@dir = dir
  end

  def self.file_path(site : String, bsid : String)
    "#{@@dir}/#{site}/#{bsid}.json"
  end

  def self.load(site, bsid)
    load(file_path(site, bsid))
  end

  def self.load(file : String)
    from_json(File.read(file))
  end
end
