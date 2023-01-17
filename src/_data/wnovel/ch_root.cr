require "../_base"
require "./nv_info"

require "../../_util/site_link"
require "../../_util/file_util"
require "../../_util/ram_cache"

# require "./nvchap/ch_list"
require "../shared/sname_map"
require "../remote/remote_info"

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
  column stype : Int16 = 0

  # seed data

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  ##########

  column utime : Int64 = 0 # seed page update time as total seconds since the epoch
  column stime : Int64 = 0 # last crawled at

  column last_sname : String = "" # seed's latest chap id
  column last_schid : String = "" # seed's latest chap id
  column chap_count : Int32 = 0   # total chapters

  column stage : Int16 = 0

  timestamps

  # ------------------------

  scope :filter_nvinfo do |nvinfo_id|
    where("nvinfo_id = #{nvinfo_id}").where("shield < 3")
  end

  getter privi_map : {Int8, Int8, Int8} do
    case self._repo.stype
    when -2 then {-1_i8, 0_i8, 0_i8}
    when  3 then {0_i8, 1_i8, 2_i8}
    else         {0_i8, 1_i8, 1_i8}
    end
  end

  def free_chap : Int32
    case self.chap_count
    when .< 120 then 40
    when .> 360 then 120
    else             self.chap_count // 3
    end
  end

  ########

  CACHED = RamCache(String, self).new(1024)

  def self.load!(nvinfo_id : Int64, sname : String, force = false)
    if nvinfo = Nvinfo.load!(nvinfo_id)
      load!(nvinfo, sname, force: force)
    else
      raise "Quyển sách không tồn tại"
    end
  end

  def self.load!(nvinfo : Nvinfo, sname : String, force = false) : self
    CACHED.get("#{nvinfo.id}/#{sname}") do
      upsert!(nvinfo, sname, nvinfo.id.to_i, force: force)
    end
  end

  def self.cache!(chroot : Chroot)
    CACHED.get("#{chroot.nvinfo_id}/#{chroot.sname}") { chroot }
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, s_bid : Int32, force = true)
    if model = find({nvinfo_id: nvinfo.id, sname: sname})
      model.tap(&.nvinfo = nvinfo)
    elsif force
      new({nvinfo: nvinfo, sname: sname, s_bid: s_bid}).tap(&.save!)
    else
      raise "Nguồn truyện không tồn tại"
    end
  end
end
