require "colorize"

require "../common/text_util"
require "../common/chap_util"
require "../common/json_data"

class ChapInfo
  include JsonData

  property scid = ""

  property zh_label = ""
  property vi_label = ""

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
      self.zh_title, self.zh_label = ChapUtil.split_label(title)
    else
      self.zh_title = ChapUtil.format_title(title)
      self.zh_label = ChapUtil.clean_spaces(label)
    end
  end

  def set_slug(title = @vi_title, max_words : Int32 = 12) : Void
    slug = TextUtil.tokenize(title).first(max_words).join("-")
    self.url_slug = slug
  end

  def slug_for(seed : String)
    "#{@url_slug}-#{seed}-#{@scid}"
  end

  def inherit(other : self, force = false) : Void
    return unless force || @scid == other.scid

    self.zh_title = other.zh_title
    self.vi_title = other.vi_title

    self.zh_title = other.zh_title
    self.zh_label = other.zh_label

    self.url_slug = other.url_slug
  end
end
