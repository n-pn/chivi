require "json"
require "colorize"
require "../utils/text_utils"
require "../utils/fix_titles"

class ChapItem
  include JSON::Serializable

  getter scid = ""

  property zh_group = ""
  property vi_group = ""

  property zh_title = ""
  property vi_title = ""

  property url_slug = ""

  def initialize(@scid : String, @zh_title : String, @zh_group : String = "")
    if group.empty?
      @zh_title, @zh_group = Utils.split_group(title)
    else
      @zh_title = Utils.format_title(title)
      @zh_group = Utils.clean_spaces(group)
    end
  end

  def zh_title=(title : String)
    return if title.empty? || title == @zh_title

    @zh_title = title
    @vi_title = ""
    @url_slug = ""
  end

  def zh_group=(group : String)
    return if group.empty? || group == @zh_group

    @zh_group = group
    @vi_group = ""
  end

  def gen_slug!(limit : Int32 = 12) : Void
    return if @vi_title.empty?
    slug = Utils.slugify(@vi_title, no_accent: true)
    @url_slug = slug.split("-").first(limit).join("-")
  end

  def slug_for(seed : String)
    "#{@url_slug}-#{seed}-#{@scid}"
  end
end
