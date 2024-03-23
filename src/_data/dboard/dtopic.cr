require "cmark"
require "../_base"

class CV::Dtopic
  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "dtopics", :postgres, strict: false

  field id : Int32, pkey: true, auto: true

  field viuser_id : Int32 = 0
  field nvinfo_id : Int32 = 0

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

  def initialize(@viuser_id, @nvinfo_id)
  end

  def set_title(title : String)
    self.title = title
    self.tslug = TextUtil.slugify(title).split('-').first(8).join('-')
  end

  MINUTES_OF_30_DAYS = 43200

  @[AlwaysInline]
  def sort_bonus
    bonus = self.nvinfo_id > 0 ? 1 : (1 - nvinfo_id.to_i)
    self.state &* MINUTES_OF_30_DAYS &* bonus
  end

  def inc_repl_count!(count : Int32 = 1)
    @repl_count = @repl_count + count
    @mtime = Time.utc.to_unix
    self.upsert!

    # self.nvinfo.update!({board_bump: self.utime})
  end

  def inc_view_count!(count : Int32 = 1)
    @view_count = @view_count + count
    self.upsert!
  end

  def inc_like_count!(value = 1)
    @like_count = @like_count + value
    self.upsert!
  end

  def htags=(htags : Array(String))
    @htags = htags.uniq!(&.downcase)
  end

  def update!(form, set_mtime = true)
    @mtime = Time.utc.to_unix if set_mtime

    self.set_title(form.title)
    self.htags = form.htags.split(",").map(&.strip)

    @ibody = form.btext
    @bhtml = PostUtil.md_to_html(form.btext)

    @brief = self.ibody.split('\n', 2).first? || ""

    self.upsert!
  end

  def save!
    upsert!
  end

  def soft_delete(admin = false)
    @state = admin ? -3 : -2
    @@db.exec "update #{@@schema.table} set state = $1 where id = $2", @state, @id
  end

  def canonical_path
    "/gd/t#{@id}-#{tslug}"
  end

  INC_REPL_SQL = "update #{@@schema.table} set repl_count = repl_count + $1, mtime = $2 where id = $3"

  def self.inc_repl_count!(id : Int32, value : Int32 = 1, mtime = Time.utc.to_unix)
    @@db.exec INC_REPL_SQL, value, mtime, id
  end
end
