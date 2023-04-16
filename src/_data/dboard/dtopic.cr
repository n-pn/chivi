require "cmark"
require "../../_util/hash_util"

require "../_base"
require "../wnovel/wninfo"
require "../member/viuser"

class CV::Dtopic
  include Clear::Model

  self.table = "cvposts"
  primary_key type: :serial

  column ii : Int32 = 1 # increase for each board
  # getter oid : String { HashUtil.encode32(ii) }

  belongs_to viuser : Viuser, foreign_key_type: Int32
  # getter viuser : Viuser { Viuser.load!(self.viuser_id) }

  belongs_to nvinfo : Wninfo, foreign_key_type: Int32
  # getter nvinfo : Wninfo { Wninfo.load!(self.nvinfo_id) }

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

  scope :filter_label do |labels|
    labels = labels.split('+').map! { |x| TextUtil.slugify(x.strip) }
    where("lslugs @> ?", labels)
  end

  scope :filter_board do |board|
    board ? where({nvinfo_id: board.id}) : with_nvinfo
  end

  scope :filter_owner do |owner|
    owner ? where({viuser_id: owner.id}) : with_viuser
  end

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

  #################

  CACHE = RamCache(Int64, self).new(1024, ttl: 10.minutes)

  def self.load!(id : Int64) : self
    CACHE.get(id) { find!({id: id}) }
  end

  # def self.init_base_topic!(nvinfo : Wninfo)
  #   cvpost = find({ii: nvinfo.dt_ii}) || new({
  #     ii:        nvinfo.dt_ii,
  #     state:     1,
  #     viuser_id: -2,
  #     nvinfo_id: nvinfo.id,
  #     labels:    "thao-luan",
  #   })

  #   intro = nvinfo.vintro.split("\n").map { |x| "> #{x}\n>\n" }.join("\n")
  #   btext = <<-MARKDOWN
  #   **Tên truyện**: #{nvinfo.vname}
  #   **Tác giả**: #{nvinfo.author.vname}

  #   ### Giới thiệu vắn tắt:

  #   #{intro.empty? ? "Cần bổ sung" : intro}
  #   MARKDOWN

  #   cvpost.update_content!({
  #     "labels": "1",
  #     "title":  "Thảo luận chung truyện #{nvinfo.vname}",
  #     "btext":  btext,
  #   }, set_utime: false)
  # end
end
