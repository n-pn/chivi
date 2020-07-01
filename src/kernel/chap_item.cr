require "json"
require "colorize"
require "../utils/text_utils"
require "../utils/fix_titles"

class ChapItem
  include JSON::Serializable

  property scid = ""
  property mftime = 0_i64

  property label_zh = "正文"
  property label_vi = "Chính văn"

  property title_zh = ""
  property title_vi = ""

  property url_slug = ""

  def initialize
  end

  def initialize(@scid : String, title : String, label : String = "")
    if label.empty?
      set_title(title)
    else
      @title_zh = Utils.format_title(title)
      @label_zh = Utils.clean_spaces(label)
    end
  end

  def set_title(title : String)
    title, label = Utils.split_label(title)
    self.title_zh = title
    self.label_zh = label
  end

  def title_zh=(title : String)
    return if title.empty? || title == @title_zh

    @title_zh = title
    @title_vi = ""
    @url_slug = ""
  end

  def label_zh=(label : String)
    return if label.empty? || label == @label_zh

    @label_zh = label
    @label_vi = ""
  end

  def gen_slug!(limit : Int32 = 12) : Void
    return if @title_vi.empty?
    slug = Utils.slugify(@title_vi, no_accent: true)
    @url_slug = slug.split("-").first(limit).join("-")
  end

  def slug_for(seed : String)
    "#{@url_slug}-#{seed}-#{@scid}"
  end
end
