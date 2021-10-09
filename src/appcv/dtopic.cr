class CV::Dtopic
  include Clear::Model

  self.table = "dtopics"
  primary_key

  belongs_to cvuser : Cvuser
  belongs_to dboard : Dboard
  column label_ids : Array(Int32) = [] of Int32

  column title : String
  column uslug : String

  column state : Int32 = 0 # 0: normal, 1: sticky, -1: locked, -2: deleted, -3: removed
  column utime : Int64 = 0 # update when new post created
  column _sort : Int32 = 0

  column posts : Int32 = 0 # post count
  column marks : Int32 = 0 # counting user bookmarks
  column views : Int32 = 0 # number of times this topic is viewed

  timestamps

  def set_title(title : String)
    self.title = title
    self.uslug = TextUtils.slugify(title)
  end

  def set_utime(utime : Int64)
    self.utime = utime
    update_sort(utime)
  end

  def update_sort(utime : Int64)
    self._sort = (utime // 60 + posts + views // 100 + marks * 5).to_i
  end

  def bump_views!
    update!({views: views + 1})
  end

  #################

  CACHE = RamCache(Int64, self).new(1024, ttl: 10.minutes)

  def self.load!(id : Int64)
    CACHE.get(id) { find!({id: id}) }
  end
end
