require "cmark"
require "../_base"

class CV::Dtopic
  include Crorm::Model
  schema "dtopics", :postgres, strict: false

  field id : Int32, pkey: true, auto: true

  field viuser_id : Int32 = 0

  # column nvinfo_id : Int32 = 0

  #####

  field title : String = ""
  field tslug : String = ""

  field ibody : String = ""
  field itype : String = "md"

  field bfull : String = ""
  field bdesc : String = ""

  field htags : Array(String) = [] of String
  field state : Int32 = 0 # 0: normal, 1: sticky, -1: locked, -2: deleted, -3: removed

  field repl_count : Int32 = 0 # comment count
  field like_count : Int32 = 0 # counting user bookmarks
  field view_count : Int32 = 0 # number of times this topic is viewed

  field ctime : Int64 = Time.utc.to_unix # created at
  field mtime : Int64 = Time.utc.to_unix # updated at

  field rtime : Int64 = 0 # when new comment/reply created
  field atime : Int64 = 0 # when new data changed

  def set_title(title : String)
    self.title = title
    self.tslug = TextUtil.slugify(title).split('-').first(8).join('-')
  end

  def set_utime(utime : Int64)
    self.utime = utime
    update_sort!
  end

  MINUTES_OF_30_DAYS = 43200

  @[AlwaysInline]
  def sort_bonus
    bonus = self.nvinfo_id > 0 ? 1 : (1 - nvinfo_id.to_i)
    self.state &* MINUTES_OF_30_DAYS &* bonus
  end

  def bump!
    self.repl_count = self.repl_count + 1
    self.set_utime(Time.utc.to_unix)
    self.save!

    self.nvinfo.update!({board_bump: self.utime})
  end

  def bump_view_count!
    self.view_count = self.view_count + 1
    update_sort!
    self.save!
  end

  def inc_like_count!(value = 1)
    self.like_count = self.like_count + value
    self.update_sort!
    self.save!
  end

  def htags=(htags : Array(String))
    @htags = htags.uniq!(&.downcase)
  end

  def update!(form, set_utime = true)
    self.set_utime(Time.utc.to_unix) if set_utime

    self.set_title(form.title)
    self.set_htags(form.htags.split(",").map(&.strip))

    @itext = form.btext
    @bhtml = PostUtil.md_to_html(form.btext)

    @brief = self.btext.split('\n', 2).first? || ""

    self.upsert!
  end

  def soft_delete(admin = false)
    update!(state: admin ? -3 : -2)
  end

  def canonical_path
    "/gd/t#{@id}-#{tslug}"
  end
end
