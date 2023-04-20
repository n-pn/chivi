require "cmark"
require "../../_util/hash_util"

require "../_base"
require "../wnovel/wninfo"
require "../member/viuser"

class CV::Dtopic
  include Clear::Model

  self.table = "cvposts"
  primary_key type: :serial

  column viuser_id : Int32 = 0

  # column nvinfo_id : Int32 = 0
  belongs_to nvinfo : Wninfo, foreign_key_type: Int32

  #####

  column title : String = ""
  column tslug : String = ""
  column brief : String = ""

  column labels : Array(String) = [] of String
  column lslugs : Array(String) = [] of String

  column btext : String = ""
  column bhtml : String = ""

  ##########

  column ptype : Int32 = 0
  column stars : Int32 = 0

  column _bump : Int32 = 0
  column _sort : Int32 = 0

  column state : Int32 = 0 # 0: normal, 1: sticky, -1: locked, -2: deleted, -3: removed
  column utime : Int64 = 0 # update when new comment created

  column repl_count : Int32 = 0 # comment count
  column like_count : Int32 = 0 # counting user bookmarks
  column view_count : Int32 = 0 # number of times this topic is viewed

  timestamps

  # scope :filter_owner do |owner|
  #   owner ? where({viuser_id: owner.id}) : with_viuser
  # end

  def set_title(title : String)
    self.title = title
    self.tslug = TextUtil.slugify(title).split('-').first(8).join('-')
  end

  def set_utime(utime : Int64)
    self.utime = utime
    update_sort!
  end

  def update_sort!
    _sort = (self.utime // 60).to_i
    _sort &+= repl_count // 3
    _sort &+= like_count // 20
    _sort &+= view_count // 60
    _sort &+= sort_bonus

    self._sort = _sort
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

  def set_labels(labels : Array(String))
    self.labels = labels.uniq!(&.downcase)
    self.lslugs = self.labels.map { |x| TextUtil.slugify(x) }
  end

  def update_content!(form, set_utime = true)
    self.set_utime(Time.utc.to_unix) if set_utime

    self.set_title(form.title)
    self.set_labels(form.labels.split(",").map(&.strip))

    self.btext = form.btext
    self.bhtml = PostUtil.md_to_html(self.btext)
    self.brief = self.btext.split("\n", 2).first? || ""

    self.save!
  end

  def soft_delete(admin = false)
    update!(state: admin ? -3 : -2)
  end

  def gen_like_notif(from_user : String)
    muhead = Muhead.find!("gd:#{self.id}")

    link_to = muhead._link
    content = <<-HTML
    <p><a href="/@#{from_user}" class="cv-user">#{from_user}</a> đã thích #{muhead._type} <a href="#{link_to}">#{muhead._name}</a> của bạn.</p>
    HTML

    details = {_type: "like-dtop", from_user: from_user, dtopic_id: self.id}
    {content, details, link_to}
  end

  #################

  CACHE = RamCache(Int32, self).new(1024, ttl: 10.minutes)

  def self.load!(id : Int32) : self
    CACHE.get(id) { find!({id: id}) }
  end
end
