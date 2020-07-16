require "colorize"

require "../common/text_util"
require "../common/json_data"
require "./chap_util"

class ChapInfo
  include JsonData

  property scid = ""

  property label_zh = ""
  property label_vi = ""

  property zh_title = ""
  property vi_title = ""

  property url_slug = ""

  def initialize(@scid = "")
  end

  def initialize(@scid : String, title : String, label : String = "正文")
    set_title(title, label)
  end

  def set_title(title : String, label : String = "正文")
    if label.empty? || label == "正文"
      self.zh_title, self.label_zh = ChapUtil.split_label(title)
    else
      self.zh_title = ChapUtil.format_title(title)
      self.label_zh = ChapUtil.clean_spaces(label)
    end
  end

  def set_slug(title = @vi_title, max_words : Int32 = 12) : Void
    slug = TextUtil.tokenize(title).first(max_words).join("-")
    self.url_slug = slug
  end

  def slug_for(seed : String)
    "#{@url_slug}-#{seed}-#{@scid}"
  end

  def inherit(other : self) : Void
    self.zh_title = other.zh_title
    self.vi_title = other.vi_title

    self.zh_title = other.zh_title
    self.label_zh = other.label_zh

    self.url_slug = other.url_slug
  end
end
