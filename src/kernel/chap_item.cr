require "json"
require "colorize"
require "../utils/text_utils"
require "../utils/fix_titles"

class ChapItem
  include JSON::Serializable

  property scid = ""

  property label_zh = ""
  property label_vi = ""

  property title_zh = ""
  property title_vi = ""

  property url_slug = ""

  @[JSON::Field(ignore: true)]
  property changed = false

  def initialize
  end

  def initialize(@scid : String, title : String, label : String = "正文")
    @changed = true

    if label.empty? || label == "正文"
      set_title(title)
    else
      @title_zh = Utils.format_title(title)
      @label_zh = Utils.clean_spaces(label)
    end
  end

  def changed?
    @changed
  end

  def mark_saved!
    @changed = false
  end

  def set_title(title : String)
    title, label = Utils.split_label(title)
    self.title_zh = title
    self.label_zh = label
  end

  def title_zh=(title : String)
    return if title == @title_zh
    @changed = true
    @title_zh = title
  end

  def title_vi=(title : String)
    return if title == @title_vi
    @changed = true
    @title_vi = title
  end

  def label_zh=(label : String)
    return if label == @label_zh
    @changed = true
    @label_zh = label
    @label_vi = ""
  end

  def label_vi=(label : String)
    return if label == @label_vi
    @changed = true
    @label_vi = label
  end

  def gen_slug!(limit : Int32 = 12) : Void
    return if @title_vi.empty?
    slug = Utils.slugify(@title_vi, no_accent: true)
    url_slug = slug.split("-").first(limit).join("-")
    return if url_slug == @url_slug

    @changed = true
    @url_slug = url_slug
  end

  def slug_for(seed : String)
    "#{@url_slug}-#{seed}-#{@scid}"
  end
end
