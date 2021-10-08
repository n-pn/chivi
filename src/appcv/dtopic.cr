class CV::Dtopic
  include Clear::Model

  self.table = "dtopics"
  primary_key

  belongs_to cvuser : Cvuser
  belongs_to dboard : Dboard
  column label_ids : Array(String) = [] of String

  column title : String
  column tslug : String
  column descs : String

  column state : Int32 = 0 # 0: normal, 1: sticky, -1: locked, -2: deleted, -3: removed
  column utime : Int64 = 0 # update when new post created
  column _sort : Int32 = 0

  column posts : Int32 = 0 # post count
  column marks : Int32 = 0 # counting user bookmarks
  column views : Int32 = 0 # number of times this topic is viewed

  timestamps

  def bump!(time = Time.utc)
    update!(atime: time.to_unix)
  end

  #################

  CACHE = RamCache(Int64, self).new(1024, ttl: 10.minutes)

  def self.load!(id : Int64)
    CACHE.get(id) { find!({id: id}) || autogen(id).tap(&.save!) }
  end
end
