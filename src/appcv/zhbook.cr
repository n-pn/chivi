require "../cutil/core_utils"

class CV::Zhbook
  include Clear::Model

  self.table = "zhbooks"
  primary_key

  belongs_to cvbook : Cvbook

  column zseed : Int32 # seed name
  column znvid : Int32 # seed book id

  column author : String = ""
  column ztitle : String = ""

  column genres : Array(String) = [] of String
  column bcover : String = ""
  column bintro : String = ""

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  column bumped : Int64 = 0 # last fetching time as total minutes since the epoch
  column mftime : Int64 = 0 # seed page update time as total seconds since the epoch

  column chap_count : Int32 = 0 # total chapters
  column last_zchid : Int32 = 0 # seed's latest chap id

  getter sname : String { Zhseed.zseed(zseed) }
  getter snvid : String { generate_snvid }
  getter last_schid : String { last_zchid.to_s }

  private def generate_snvid
    return znvid.to_s unless sname == "zhwenpg"
    CoreUtils.encode32_zh(znvid).ljust(6, '2')
  end

  def last_zchid=(schid : String)
    @last_schid = schid
    self.last_zchid = schid.to_i
  end

  def self.upsert!(zseed : Int32, znvid : Int32)
    find({zseed: zseed, znvid: znvid}) || new({zseed: zseed, znvid: znvid})
  end

  def self.upsert!(sname : String, snvid : String)
    zseed = Zhseed.index(sname)
    znvid = sname == "zhwenpg" ? CoreUtils.decode32_zh(snvid).to_i : snvid.to_i
    upsert!(zseed, znvid)
  end
end
