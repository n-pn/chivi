require "json"

class VpBook
  include JSON::Serializable

  property zh_slug : String = ""
  property vi_slug : String = ""

  property zh_title : String = ""
  property vi_title : String = ""

  property zh_author : String = ""
  property vi_author : String = ""

  property zh_intro : String = ""
  property vi_intro : String = ""

  property zh_genre : String = ""
  property vi_genre : String = ""

  property zh_tags : Array(String) = [] of String
  property vi_tags : Array(String) = [] of String

  property covers : Array(String) = [] of String

  property status : Int32 = 0
  property hidden : Int32 = 0

  property votes : Int32 = 0
  property score : Float64 = 0
  property tally : Float64 = 0

  property word_count : Int32 = 0
  property chap_count : Int32 = 0

  property review_count : Int32 = 0

  property updated_at : Int64 = 0

  property yousuu_bids : Array(Int32) = [] of Int32
  property source_urls : Array(String) = [] of String
  property scrap_links : Hash(String, String) = {} of String => String
  property favor_scrap : String = ""

  def initialize
  end

  def format_intro!
    return if @zh_intro.empty?

    @zh_intro = @zh_intro
      .tr("　 ", " ")
      .gsub("&lt;", "<")
      .gsub("&gt;", ">")
      .gsub("<br>", "\n")
      .gsub("<br/>", "\n")
      .gsub("&nbsp;", " ")
      .gsub(/\s{2,}/, "\n")
      .split("\n")
      .map(&.strip)
      .reject(&.empty?)
      .join("\n")
  end

  def clean_tags!
    @zh_tags = @zh_tags.map(&.split("-")).flatten.uniq
    @zh_tags = @zh_tags.reject do |tag|
      tag == @zh_genre || tag == @zh_title || tag == @zh_author
    end
  end
end
