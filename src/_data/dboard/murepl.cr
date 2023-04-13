require "../_base"
require "../../_util/post_util"

class CV::Murepl
  # note: mu stand for multiuse/multipurpose
  # convention:
  # - for wnovel general discussion, thread_id = -wnovel_id * 2, thread_mu = 0
  # - for wnovel chapter discussion, thread_id = -wnseed_id * 2 + 1, thread_mu = -ch_no
  # - for dboard general discussion, thread_id = dtopic_id, thread_mu = 0

  # - for cvuser review comments, thread_id = vicrit_id, thread_mu = 10
  # - for cvuser booklist comments, thread_id = vilist_id, thread_mu = 11

  # - for member page public comment, thread_id = viuser_id, thread_mu = 20
  # - for author page public comment, thread_id = author_id, thread_mu = 21

  # - for yousuu review comments, thread_id = yscrit_id, thread_mu = 50
  # - for yousuu booklist comments, thread_id = yslist_id, thread_mu = 51

  # pending:
  # - dictionary translation?

  include Clear::Model

  self.table = "murepls"
  primary_key type: :serial

  column viuser_id : Int32 = 0

  column thread_id : Int32 = 0
  column thread_mu : Int16 = 0 # multipurpose field

  column touser_id : Int32 = 0 # parent viuser_id
  column torepl_id : Int32 = 0 # parent murepl_id

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

  def bump_parent_on_create!
    case self.thread_mu
    when 0 # mark dtopic
      # TODO: rename cvposts to dtopics
      Clear::SQL.execute <<-SQL
        update cvposts set
          repl_count = reply_count + 1, utime = #{self.utime}
        where id = #{self.thread_id}
      SQL
    end
  end

  #################

  CACHE = RamCache(Int32, self).new(1024, ttl: 20.minutes)

  def self.load!(id : Int32)
    CACHE.get(id) { find!({id: id}) }
  end
end
