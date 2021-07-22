require "../cutil/core_utils"

class CV::Zhbook
  include Clear::Model

  self.table = "zhbooks"
  primary_key

  belongs_to cvbook : Cvbook

  column zseed : Int32 # seed name
  getter sname : String { Zhseed.zseed(zseed) }

  column snvid : String # seed book id

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  column bumped : Int64 = 0 # last fetching time as total minutes since the epoch
  column mftime : Int64 = 0 # seed page update time as total seconds since the epoch

  column chap_count : Int32 = 0   # total chapters
  column last_schid : String = "" # seed's latest chap id

  getter chinfo : ChInfo { ChInfo.new(cvbook.bhash, sname, snvid) }

  def unmatch?(cvbook_id : Int64) : Bool
    cvbook_id_column.value(0) != cvbook_id
  end

  def refresh!(privi = 4, mode = 0, ttl = 5.minutes) : Tuple(Int64, Int32)
    return {mftime, chap_count} unless mode > 0 && remote?(privi)

    RmInfo.mkdir!(sname)
    parser = RmInfo.new(sname, snvid, ttl: ttl)

    if mode > 1 || parser.last_schid != self.last_schid
      self.mftime = parser.mftime > 0 ? parser.mftime : Time.utc.to_unix

      self.chap_count = parser.chap_list.size
      self.last_schid = parser.last_schid
      self.bumped = Time.utc.to_unix

      chinfo.save_seeds!(parser.chap_list)
      chinfo.reset_trans!

      self.save!
    end

    {mftime, chap_count}
  end

  def remote?(privi : Int32 = 4)
    case sname
    when "chivi", "zxcs_me"
      false
    when "5200", "bqg_5200", "rengshu", "nofff"
      true
    when "hetushu", "biqubao", "bxwxorg", "xbiquge"
      privi > 0
    when "zhwenpg", "69shu", "paoshu8", "duokan8"
      privi > 1
    else
      privi > 3
    end
  end

  def self.upsert!(zseed : Int32, snvid : String)
    find({zseed: zseed, snvid: snvid}) || new({zseed: zseed, snvid: snvid})
  end

  def self.upsert!(sname : String, snvid : String)
    upsert!(Zhseed.index(sname), snvid)
  end

  CACHE = {} of Int64 => self

  def self.load!(cvbook : Cvbook, zseed : Int32)
    CACHE[cvbook.id << 6 | zseed] ||=
      case zseed
      when 1 then dummy(cvbook)
      else        find!({cvbook_id: cvbook.id, zseed: zseed})
      end
  end

  def self.dummy(cvbook : Cvbook)
    new({
      cvbook_id: cvbook.id,

      zseed: 0,
      snvid: cvbook.bhash,

      # status: cvbook.status,
      # shield: cvbook.shield,

      mftime: cvbook.mftime,
      bumped: cvbook.bumped,

      chap_count: cvbook.chap_count,
      last_schid: cvbook.chap_count.to_s.rjust(4, '0'),
    })
  end
end
