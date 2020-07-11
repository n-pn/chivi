require "colorize"
require "./base_model"
require "../_utils/fix_titles"
require "../_utils/text_utils"

class ChapItem
  include BaseModel

  property scid = ""

  property label_zh = ""
  property label_vi = ""

  property title_zh = ""
  property title_vi = ""

  property url_slug = ""

  def initialize(@scid = "")
  end

  def initialize(@scid : String, title : String, label : String = "正文")
    set_title(title, label)
  end

  def set_title(title : String, label : String = "正文")
    if label.empty? || label == "正文"
      self.title_zh, self.label_zh = Utils.split_label(title)
    else
      self.title_zh = Utils.format_title(title)
      self.label_zh = Utils.clean_spaces(label)
    end
  end

  def set_slug(title = @title_vi, max_words : Int32 = 12) : Void
    slug = Utils.slugify(title, no_accent: true)
    slug = slug.split("-").first(max_words).join("-")
    self.url_slug = slug
  end

  def slug_for(seed : String)
    "#{@url_slug}-#{seed}-#{@scid}"
  end
end
