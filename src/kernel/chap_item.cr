require "colorize"
require "./base_model"
require "../_utils/fix_titles"
require "../_utils/text_utils"

class ChapItem
  include BaseModel

  property scid = ""
  property slug = ""

  property label = ""
  property title = ""

  def initialize(@scid = "")
  end

  def initialize(@scid : String, title : String, label : String = "正文")
    if label.empty? || label == "正文"
      set_title(title)
    else
      @title = Utils.format_title(title)
      @label = Utils.clean_spaces(label)
      @changes = 1
    end
  end

  def set_title(input : String)
    self.title, self.label = Utils.split_label(input)
  end

  def set_slug(title : String, max_words : Int32 = 12) : Void
    slug = Utils.slugify(title, no_accent: true)
    slug = slug.split("-").first(max_words).join("-")
    self.slug = slug
  end

  def slug_for(seed : String)
    "#{@slug}-#{seed}-#{@scid}"
  end
end
