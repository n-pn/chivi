require "../_util/site_link"
require "../_util/file_util"
require "../_util/ram_cache"

# require "./nvchap/ch_list"
require "./shared/sname_map"
require "./remote/remote_info"

require "./chroot/*"

class CV::Chroot
  include Clear::Model

  self.table = "chroots"
  primary_key type: :serial

  # column uid : Int64 = 0_i64 # alternative unique index

  belongs_to nvinfo : Nvinfo
  getter nvinfo : Nvinfo { Nvinfo.load!(self.nvinfo_id) }

  column sname : String = ""
  column s_bid : Int32 # seed book id

  # column snvid : String = ""
  column zseed : Int32 = 0

  # seed data

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  ##########

  column utime : Int64 = 0 # seed page update time as total seconds since the epoch
  column stime : Int64 = 0 # last crawled at

  column last_sname : String = ""   # seed's latest chap id
  column last_schid : String = ""   # seed's latest chap id
  column chap_count : Int16 = 0_i16 # total chapters

  column stage : Int16 = 0
  column seeded : Bool = false

  timestamps

  # ------------------------

  scope :filter_nvinfo do |nvinfo_id|
    where("nvinfo_id = #{nvinfo_id}").where("shield < 3")
  end

  getter seed_type : Int32 { SnameMap.map_type(sname) }

  getter privi_map : {Int8, Int8, Int8} do
    case self.seed_type
    when 0 then {-1_i8, 0_i8, 0_i8}
    when 3 then {0_i8, 1_i8, 2_i8}
    else        {0_i8, 1_i8, 1_i8}
    end
  end

  def min_privi(chidx : Int16, chars : Int32 = 0)
    privi_map = self.privi_map
    case
    when chidx <= self.free_chap then privi_map[0]
    when chars > 0               then privi_map[1]
    else                              privi_map[2]
    end
  end

  def free_chap
    case chap_count
    when .< 120 then 40_i16
    when .> 360 then 120_i16
    else             chap_count // 3
    end
  end

  ########

  CACHED = RamCache(String, self).new(1024)

  def self.load!(nvinfo_id : Int64, sname : String, force = false)
    raise "Quyển sách không tồn tại" unless nvinfo = Nvinfo.load!(nvinfo_id)
    load!(nvinfo, sname, force: force)
  end

  def self.load!(nvinfo : Nvinfo, sname : String, force = false) : self
    CACHED.get("#{nvinfo.id}/#{sname}") do
      upsert!(nvinfo, sname, nvinfo.id.to_i, force: force)
    end
  end

  def self.cache!(chroot : Chroot)
    CACHED.get("#{chroot.nvinfo_id}/#{chroot.sname}") do
      chroot.tap(&.reload!(mode: 0_i8))
    end
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, s_bid : Int32, force = true)
    if chroot = find({nvinfo_id: nvinfo.id, sname: sname})
      chroot.tap(&.reload!(mode: 0_i8))
    elsif force
      model = new({nvinfo: nvinfo, sname: sname, s_bid: s_bid})
      model.zseed = SnameMap.zseed(sname)
      model.tap(&.save!)
    else
      raise "Nguồn truyện không tồn tại"
    end
  end
end
