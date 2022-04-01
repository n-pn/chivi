require "cmark"
require "../_util/ukey_util"

class CV::Dtopic
  include Clear::Model

  self.table = "dtopics"
  primary_key

  column ii : Int32 = 1 # increase for each board
  getter oid : String { UkeyUtil.encode32(ii) }

  belongs_to cvuser : Cvuser
  getter cvuser : Cvuser { Cvuser.load!(self.cvuser_id) }

  belongs_to nvinfo : Nvinfo
  getter nvinfo : Nvinfo { Nvinfo.load!(self.nvinfo_id) }

  belongs_to dtbody : Dtpost
  belongs_to lasttp : Dtpost

  column dlabel_ids : Array(Int32) = [] of Int32
  column labels : Array(String) = [] of String

  column title : String = ""
  column tslug : String = ""
  column brief : String = ""

  column state : Int32 = 0 # 0: normal, 1: sticky, -1: locked, -2: deleted, -3: removed
  column utime : Int64 = 0 # update when new post created
  column _sort : Int32 = 0

  column post_count : Int32 = 0 # post count
  column like_count : Int32 = 0 # counting user bookmarks
  column view_count : Int32 = 0 # number of times this topic is viewed

  timestamps

  scope :filter_label do |label|
    if label_id = label.try(&.to_i?)
      where("dlabel_ids @> ?", [label_id])
    else
      self
    end
  end

  scope :filter_board do |board|
    board ? where({nvinfo_id: board.id}) : with_nvinfo
  end

  scope :filter_owner do |owner|
    owner ? where({cvuser_id: owner.id}) : with_cvuser
  end

  def set_title(title : String)
    self.title = title
    uslug = TextUtil.slugify(title).split("-").first(8).join("-")
    self.tslug = uslug.size < 48 ? uslug : uslug[0..40]
  end

  def set_utime(utime : Int64)
    self.utime = utime
    update_sort!
  end

  def update_sort!
    _sort = (self.utime // 60).to_i + post_count // 3 + like_count // 20 + view_count // 60
    self._sort = _sort &+ sort_bonus
  end

  MINUTES_OF_30_DAYS = 43200

  @[AlwaysInline]
  def sort_bonus
    bonus = self.nvinfo_id > 0 ? 1 : (1 - nvinfo_id.to_i)
    self.state &* MINUTES_OF_30_DAYS &* bonus
  end

  def bump_post_count!
    # @lastrp = nil

    self.post_count = self.post_count + 1
    set_utime(Time.utc.to_unix)
    self.nvinfo.update!({board_bump: self.utime})

    self.save!
  end

  def bump_view_count!
    self.view_count = self.view_count + 1
    update_sort!
    self.save!
  end

  def bump_like_count!
    self.like_count = self.like_count + 1
    update_sort!
    self.save!
  end

  def update_content!(params, set_utime = true)
    set_utime(Time.utc.to_unix) if set_utime

    set_title(params["title"])
    self.dlabel_ids = params["labels"].split(",").compact_map(&.strip.to_i?)

    self.save! unless @id_column.defined? # make id column available

    self.dtbody.cvuser_id = self.cvuser_id
    self.dtbody.set_input(params["body_input"], params["body_itype"])
    self.dtbody.save!

    self.brief = dtbody.otext.split("\n", 2).first? || ""
    self.dtbody_id = self.dtbody.id

    self.save!
  end

  def soft_delete(admin = false)
    update!(state: admin ? -3 : -2)
  end

  #################

  CACHE = RamCache(Int64, self).new(1024, ttl: 10.minutes)

  def self.load!(ii : Int64) : self
    CACHE.get(ii) { find!({ii: ii}) }
  end

  def self.load!(ii : String) : self
    load!(UkeyUtil.decode32(ii))
  end

  def self.init_base_topic!(nvinfo : Nvinfo)
    dtopic = find({ii: nvinfo.dt_ii}) || new({
      ii:        nvinfo.dt_ii,
      state:     1,
      cvuser_id: -2,
      nvinfo_id: nvinfo.id,
      labels:    "thao-luan",
    })

    bintro = nvinfo.vintro.split("\n").map { |x| "> #{x}\n>\n" }.join("\n")
    tpbody = <<-MARKDOWN
    **Tên truyện**: #{nvinfo.vname}
    **Tác giả**: #{nvinfo.author.vname}

    ### Giới thiệu vắn tắt:

    #{bintro.empty? ? "Cần bổ sung" : bintro}
    MARKDOWN

    dtopic.update_content!({
      "title":      "Thảo luận chung truyện #{nvinfo.vname}",
      "labels":     "1",
      "body_input": tpbody,
      "body_itype": "md",
    }, set_utime: false)
  end
end
