require "cmark"

class CV::Dtopic
  include Clear::Model

  self.table = "dtopics"
  primary_key

  belongs_to cvuser : Cvuser
  belongs_to dboard : Dboard

  column dlabel_ids : Array(Int32) = [] of Int32

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
    label ? where("dlabel_ids @> ?", [label.to_i]) : self
  end

  scope :filter_board do |board|
    board ? where({dboard_id: board.id}) : with_dboard
  end

  scope :filter_owner do |owner|
    owner ? where({cvuser_id: owner.id}) : with_cvuser
  end

  getter dtbody : Dtpost do
    params = {dtopic_id: self.id, dt_id: 0}
    Dtpost.find(params) || Dtpost.new(params)
  end

  def set_title(title : String)
    self.title = title
    self.tslug = TextUtils.slugify(title)
  end

  def set_utime(utime : Int64)
    self.utime = utime
    update_sort!
  end

  def update_sort!
    self._sort = (self.utime // 60).to_i + post_count + view_count // 100 + like_count * 5
  end

  def bump_post_count!
    self.post_count = self.post_count + 1
    set_utime(Time.utc.to_unix)
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

  def update_content!(params)
    set_utime(Time.utc.to_unix)

    set_title(params["title"])
    self.dlabel_ids = params.json("labels").as_a.map(&.as_i)

    self.save! unless @id_column.defined? # make id column available

    self.dtbody.cvuser_id = self.cvuser_id
    self.dtbody.set_input(params["body_input"], params["body_itype"])
    self.dtbody.save!

    self.brief = dtbody.otext.split("\n", 2).first? || ""
    self.save!
  end

  def solf_delete(admin = false)
    update!(state: admin ? -3 : -2)
  end

  #################

  CACHE = RamCache(Int64, self).new(1024, ttl: 10.minutes)

  def self.load!(id : Int64)
    CACHE.get(id) { find!({id: id}) }
  end
end
