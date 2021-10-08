class CV::Dboard
  include Clear::Model

  self.table = "dboards"
  primary_key

  # has_many dtopics : Dtopic, foreign_key: "dtopic_id"

  column bname : String
  column bslug : String

  column topics : Int32 = 0
  column tposts : Int32 = 0

  column stars : Int32 = 0
  column views : Int32 = 0

  column utime : Int64 = 0
  column atime : Int64 = 0

  timestamps

  def bump!(time = Time.utc)
    update!(atime: time.to_unix)
  end

  #################

  CACHE_INT = RamCache(Int64, self).new(2048, ttl: 2.hours)
  CACHE_STR = RamCache(String, self).new(2048, ttl: 2.hours)

  def self.load!(id : Int64)
    CACHE_INT.get(id) { find!({id: id}) || autogen(id).tap(&.save!) }
  end

  def self.load!(bslug : String)
    CACHE_STR.get(bslug) { load!(guess_id(bslug)) }
  end

  def self.guess_id(bslug : String) : Int64
    case bslug
    when "dai-sanh"  then 0_i64
    when "thong-cao" then -1_i64
    when "quang-ba"  then -2_i64
    else
      raise "Unknown book!" unless cvbook = Cvbook.load!(bslug)
      cvbook.id
    end
  end

  def self.autogen(id : Int64)
    bname, bslug =
      case id
      when  0_i64 then {"Đại sảnh", "dai-sanh"}   # general place
      when -1_i64 then {"Thông cáo", "thong-cao"} # show in top of board list
      when -2_i64 then {"Quảng bá", "quang-ba"}   # show in every page
      else
        raise "Unknown book!" unless cvbook = Cvbook.load!(id)
        {cvbook.vtitle, cvbook.bslug}
      end

    atime = utime = Time.utc.to_unix
    new({id: id, bname: bname, bslug: bslug, atime: atime, utime: utime})
  end
end
