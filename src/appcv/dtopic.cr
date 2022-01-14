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
    update_sort(utime)
  end

  def update_sort(utime : Int64)
    self._sort = (utime // 60 + post_count + view_count // 100 + like_count * 5).to_i
  end

  def bump_view_count!
    update!({view_count: view_count + 1})
  end

  def save_content!
    self.save!
    self.dtbody.save!
  end

  #################

  CACHE = RamCache(Int64, self).new(1024, ttl: 10.minutes)

  def self.load!(id : Int64)
    CACHE.get(id) { find!({id: id}) }
  end
end
