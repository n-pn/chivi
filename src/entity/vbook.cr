require "json"
require "colorize"
require "../engine"

require "./sbook"
require "./vsite"
require "./vtran"

class VBook
  include JSON::Serializable

  property label = VTran.new
  property title = VTran.new
  property author = VTran.new
  property genre = VTran.new
  property tags = Array(VTran).new

  property intro_zh = ""
  property intro_vi = ""

  property cover_urls = [] of String
  property cover_file = "blank.jpg"

  property status = 0
  property hidden = 0

  property votes = 0
  property score = 0_f64
  property tally = 0_f64

  property word_count = 0
  property review_count = 0

  property updated_at = 0_i64

  property yousuu_bids = [] of Int32
  property source_urls = [] of String

  property scrap_sites = {} of String => VSite
  property prefer_site = ""
  property prefer_bsid = ""

  def initialize
  end

  def to_s(io : IO)
    io << to_pretty_json
  end

  def update(other : SBook, book : String? = nil, user : String = "local")
    changed = false

    if @genre.zh.empty? && !other.genre.empty?
      update_genre(other.genre)
      changed = true
    end

    unless other.tags.empty?
      old_size = @tags.size
      update_tags(other.tags)
      changed = true if @tags.size > old_size
    end

    if @intro_zh.empty? && !other.intro.empty?
      update_intro(other.intro, book, user)
      changed = true
    end

    unless other.cover_link.empty?
      @cover_urls << other.cover_link
      if @cover_file == "blank.jpg"
        @cover_file = other.cover_file
        changed = true
      end
    end

    if other.status > @status
      @status = other.status
      changed = true
    end

    if other.mtime > @mtime
      @mtime = other.mtime
      changed = true
    end

    if @prefer_site.empty?
      @prefer_site = other.site
      @prefer_bsid = other.bsid
      changed = true
    end

    if site = @scrap_sites[other.site]?
      if other.mtime > site.mtime
        site.mtime = other.mtime
        changed = true
      end

      if other.chaps > site.chaps
        site.chaps = other.chaps
        changed = true
      end
    else
      @scrap_sites[other.site] = VSite.new(other)
    end

    changed
  end

  def save!(dir : String = "data/txt-out/serials", name : String = @label_us) : Void
    file = "#{dir}/#{name}.json"
    puts "- saved book <#{file.colorize(:green)}>"
    File.write(file, to_json)
  end

  def update_title(title_zh : String, title_vi : String? = nil)
    title_hv = Engine.hanviet(title_zh, apply_cap: true).vi_text
    title_vi ||= title_hv
    @title.update(title_zh, title_vi, title_hv)
  end

  def update_author(author_zh : String, author_vi : String? = nil)
    author_hv = CUtil.titlecase(Engine.hanviet(author_zh).vi_text)
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
      @tags << VTran.new(tag_zh, tag_vi, tag_vi)
    end
  end
end
