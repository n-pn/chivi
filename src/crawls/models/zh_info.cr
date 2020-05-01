require "json"

require "../../utils/hash_id"

class ZhInfo
  include JSON::Serializable

  property site = ""
  property bsid = ""

  property title = ""
  property author = ""

  property intro = ""
  property genre = ""

  property tags = [] of String
  property cover = ""

  property state = 0_i32
  property mtime = 0_i64

  def initialize(@site : String, @bsid : String)
  end

  def label
    "#{title}--#{author}"
  end

  def hash
    Utils.hash_id(label)
  end

  def title=(title : String)
    @title = title.sub(/\(.+\)$/, "").strip
  end

  def author=(author : String)
    @author = author.sub(/\(.+\)$/, "").sub(".QD", "").strip
  end

  def genre=(genre : String)
    @genre = genre.strip
  end

  def tags=(tags : Array(String))
    @tags = tags.reject do |tag|
      tag == @genre || tag == @title || tag == @author
    end
  end

  def intro=(intro : String)
    @intro = intro.tr("　 ", " ")
      .gsub("&amp;", "&")
      .gsub("&lt;", "<")
      .gsub("&gt;", ">")
      .gsub("<br>", "\n")
      .gsub("<br/>", "\n")
      .gsub("&nbsp;", " ")
      .split(/\s{2,}|\n+/)
      .map(&.strip)
      .reject(&.empty?)
      .join("\n")
  end
end
