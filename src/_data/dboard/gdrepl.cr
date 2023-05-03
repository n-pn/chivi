require "../../_util/post_util"
require "../_base"

require "../member/viuser"
require "../wnovel/wninfo"

require "./gdroot"
require "./dtopic"

class CV::Gdrepl
  include Clear::Model

  self.table = "rpnodes"
  primary_key type: :serial

  column viuser_id : Int32 = 0
  column gdroot_id : Int32 = 0

  column touser_id : Int32 = 0 # parent viuser_id
  column torepl_id : Int32 = 0 # parent rpnode_id

  column level : Int16 = 0 # nesting level
  column utime : Int64 = 0 # update when new post created/updated

  column itext : String = ""
  column ohtml : String = ""

  column like_count : Int32 = 0 # like count
  column repl_count : Int32 = 0 # repl count

  column gift_vcoin : Int32 = 0 # reward given by users

  column tagged_ids : Array(Int32) = [] of Int32

  column deleted_at : Time? = nil
  column deleted_by : Int32? = nil

  timestamps

  scope :sort_by do |order|
    case order
    when "-id" then order_by(id: :desc)
    else            order_by(id: :asc)
    end
  end

  def repl_peak
    TextUtil.truncate(self.itext, 100)
  end

  def update_content!(itext : String, persist : Bool = true)
    self.utime = Time.utc.to_unix
    self.set_itext(itext)
    self.save! if persist
  end

  def set_itext(itext : String)
    self.itext = itext
    self.ohtml, users = PostUtil.render_md(itext)
    self.tagged_ids = Viuser.query.where("uname = any (?)", users).map(&.id)
  end

  def inc_like_count!(value = 1, persist = true)
    self.like_count = self.like_count &+ value
    self.save! if persist
  end

  #################

  CACHE = RamCache(Int32, self).new(1024, ttl: 20.minutes)

  def self.load!(id : Int32)
    CACHE.get(id) { find!({id: id}) }
  end

  def self.get_all(gdroot_id : Int32)
    self.query.where("gdroot_id = ?", gdroot_id).to_a

    # PGDB.query_all <<-SQL, gdroot_id, as: self
    #   select * from #{@@table}
    #   where gdroot_id = $1  and id > 0
    #   SQL
  end

  def self.repl_count(gdroot_id : Int32)
    PGDB.query_one <<-SQL, gdroot_id, as: Int32
      select coalesce(count(*)) from #{@@table}
      where gdroot_id = $1 and id > 0
      SQL
  end

  def self.member_ids(gdroot_id : Int32)
    PGDB.query_all <<-SQL, gdroot_id, as: Int32
      select distinct(viuser_id) from #{@@table}
      where gdroot_id = $1
    SQL
  end
end
