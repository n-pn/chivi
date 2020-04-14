require "json"
require "colorize"
require "../engine"

require "./sbook"

class VBook
  class Scrap
    include JSON::Serializable

    property bsid = ""
    property mtime = 0_i64
    property count = 0

    def initialize(@bsid, @mtime, @count)
    end
  end

  class Trans
    include JSON::Serializable

    property zh = ""
    property vi = ""
    property hv = ""
    property us = ""

    def initialize(zh = "", vi = "", hv = "", us = "")
      update(zh, vi, hv, us) unless zh.empty?
    end

    def update(@zh = "", @vi = "", @hv = "", @us = "")
      @vi = Engine.convert(@zh).vi_text if @vi.empty?
      @hv = Engine.hanviet(@zh).vi_text if @vi.empty?
      @us = CUtil.slugify(@vi, no_accent: true) if @us.empty?
    end

    def to_s(io : IO)
      io << to_pretty_json
    end
  end

  include JSON::Serializable

  property label = Trans.new
  property title = Trans.new
  property author = Trans.new
  property genre = Trans.new
  property tags = Array(Trans).new

  property intro_zh = ""
  property intro_vi = ""

  property covers = [] of String
  property status = 0
  property hidden = 0

  property votes = 0
  property score = 0_f64
  property tally = 0_f64

  property word_count = 0
  property chap_count = 0
  property review_count = 0

  property updated_at = 0_i64

  property yousuu_bids = [] of Int32
  property source_urls = [] of String

  property scrap_links = {} of String => Scrap
  property prefer_site = ""
  property prefer_bsid = ""

  def initialize
  end

  def to_s(io : IO)
    io << to_pretty_json
  end

  def update(other : SBook, book : String? = nil, user : String = "local")
    changed = false

    if @intro_zh.empty? && !other.intro.empty?
      update_intro(other.intro, book, user)
      changed = true
    end

    if @genre_zh.empty? && !other.genre.empty?
      update_genre(other.genre, book, user)
      changed = true
    end

    if other.status > @status
      @status = other.status
      changed = true
    end

    changed
  end

  def save!(@dir : String = "data/txt-out/serials", name : String = @label_us) : Void
    file = File.join(@dir, "#{name}.json")
    puts "- saved book <#{file.colorize(:green)}>"
    File.write(file, to_json)
  end

  def update_title(title_zh : String, title_vi : String? = nil)
    title_hv = Engine.hanviet(title_zh, apply_cap: true).vi_text
    title_vi ||= title_hv
    @title.update(title_zh, title_vi, title_hv)
  end

  def update_author(author_zh : String, author_vi : String? = nil)
    author_hv = CUtil.titlecase(Engine.hanviet(author_zh))
    author_vi ||= author_hv
    @author.update(author_zh, author_vi, author_hv)
  end

  def update_intro(intro : String, book : String? = nil, user = "local", replace = false)
    return unless replace || @intro_zh.empty?

    lines = intro
      .gsub("&lt;", "<")
      .gsub("&gt;", ">")
      .gsub(/<br\s*\/*>/, "\n")
      .gsub("&nbsp;", " ")
      .tr("　 ", " ")
      .split(/\r|\n|\s{2,}/)
      .map(&.strip)
      .reject(&.empty?)

    @intro_zh = lines.join("\n")
    @intro_vi = Engine.convert(lines, book, user).vi_text.join("\n")
  end

  def update_genre(genre_zh : String, genre_vi : String? = nil, replace : Bool = false)
    if replace || @genre.zh.empty?
      genre_hv = Engine.hanviet(genre_zh).vi_text
      genre_vi ||= genre_hv
      @genre.update(genre_zh, genre_vi, genre_hv)
    else
      update_tags(genre_zh)
    end
  end

  def update_tags(tags : String)
    update_tags(tags.split("-"))
  end

  def update_tags(tags : Array(String))
    tags.each do |tag_zh|
      next if tag_zh == @genre.zh
      next if tag_zh == @title.zh
      next if tag_zh == @author.zh
      next if @tags.index(&.zh.==(tag_zh))

      tag_vi = Engine.hanviet(tag_zh).vi_text
      @tags << Trans.new(tag_zh, tag_vi, tag_vi)
    end
  end
end
