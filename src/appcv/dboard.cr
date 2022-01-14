class CV::Dboard
  include Clear::Model

  self.table = "dboards"
  primary_key

  # has_many dtopics : Dtopic, foreign_key: "dtopic_id"

  column bname : String
  column bslug : String

  column posts : Int32 = 0
  column views : Int32 = 0

  timestamps

  def bump!(time = Time.utc)
    update!({updated_at: time})
  end

  def bump_view_count!
    update!({views: views + 1})
  end

  def bump_post_count!
    update!({posts: posts + 1})
    Nvinfo.load!(id).update!({dtopic_count: posts}) if id > 0
  end

  #################

  CACHE_INT = RamCache(Int64, self).new(2048, ttl: 2.hours)
  CACHE_STR = RamCache(String, self).new(2048, ttl: 2.hours)

  def self.load!(id : Int64) : self
    CACHE_INT.get(id) { find({id: id}) || init!(id) }
  end

  def self.load!(bslug : String) : self
    CACHE_STR.get(bslug) { load!(guess_id(bslug)) }
  end

  def self.init!(id : Int64) : self
    bname, bslug = map_id_to_name(id)
    new({id: id, bname: bname, bslug: bslug}).tap(&.save!)
  end

  def self.map_id_to_name(id : Int64) : {String, String}
    case id
    when -1_i64 then {"Đại sảnh", "dai-sanh"}   # general place
    when -2_i64 then {"Thông cáo", "thong-cao"} # show in top of board list
    when -3_i64 then {"Quảng bá", "quang-ba"}   # show in every page
    else
      raise "Unknown book!" unless nvinfo = Nvinfo.load!(id)
      {nvinfo.vname, nvinfo.bslug}
    end
  end

  def self.guess_id(bslug : String) : Int64
    case bslug
    when "dai-sanh"  then -1_i64
    when "thong-cao" then -2_i64
    when "quang-ba"  then -3_i64
    else
      Nvinfo.load!(bslug).try(&.id) || raise "Unknown books!"
    end
  end
end
