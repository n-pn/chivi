require "json"
require "colorize"
require "../utils/text_utils"
require "../utils/fix_titles"

class ChapItem
  include JSON::Serializable

  getter scid = ""

  property group_zh = ""
  property group_vi = ""

  property title_zh = ""
  property title_vi = ""
  property title_us = ""

  property mftime = 0_i64

  def initialize
  end

  def initialize(@scid : String, @title_zh : String, @group_zh : String = "")
    if group.empty?
      @title_zh, @group_zh = Utils.split_group(title)
    else
      @title_zh = Utils.format_title(title)
      @group_zh = Utils.clean_spaces(group)
    end
  end

  def title_zh=(title : String)
    return if title.empty? || title == @title_zh

    @title_zh = title
    @title_vi = ""
    @title_us = ""
  end

  def group_zh=(group : String)
    return if group.empty? || group == @group_zh

    @group_zh = group
    @group_vi = ""
  end

  def gen_slug!(limit : Int32 = 12) : Void
    return if @title_vi.empty?
    slug = Utils.slugify(@title_vi, no_accent: true)
    @title_us = slug.split("-").first(limit).join("-")
  end

  def slug_for(seed : String)
    "#{@title_us}-#{seed}-#{@scid}"
  end
end
