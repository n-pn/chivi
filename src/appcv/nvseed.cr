require "../_util/site_link"
require "../_util/file_util"
require "../_init/remote_info"

require "./nvchap/ch_list"
require "./shared/sname_map"

require "./nvseed/*"

class CV::Nvseed
  include Clear::Model

  self.table = "nvseeds"
  primary_key

  # column uid : Int64 = 0_i64 # alternative unique index

  belongs_to nvinfo : Nvinfo
  getter nvinfo : Nvinfo { Nvinfo.load!(self.nvinfo_id) }

  column sname : String = ""
  column snvid : String # seed book id
  column zseed : Int32 = 0

  # seed data

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  ##########

  column utime : Int64 = 0 # seed page update time as total seconds since the epoch
  column stime : Int64 = 0 # last crawled at

  column last_sname : String = "" # seed's latest chap id
  column last_schid : String = "" # seed's latest chap id
  column chap_count : Int32 = 0   # total chapters

  timestamps

  def clink(schid : String) : String
    SiteLink.text_url(sname, snvid, schid)
  end

  # ------------------------

  def refresh!(mode : Int32 = 1) : Nil
    self.stime = Time.utc.to_unix

    case sname
    when "=base" then self.reload_base!(mode: mode)
    when "=user" then self.reload_user!(mode: mode)
    when .starts_with?('@')
      self.reload_self!(mode: mode)
    else
      if remote?(force: mode > 0)
        self.update_remote!(mode: mode)
      else
        self.reset_cache!
      end
    end

    self.nvinfo.save! if self.nvinfo.changed?
    Nvinfo.cache!(self.nvinfo)
  end

  ########

  CACHED = RamCache(String, self).new(1024)

  def self.load!(nvinfo_id : Int64, sname : String, force = false)
    raise "Quyển sách không tồn tại" unless nvinfo = Nvinfo.load!(nvinfo_id)
    load!(nvinfo, sname, force: force)
  end

  def self.load!(nvinfo : Nvinfo, sname : String, force = false) : self
    CACHED.get("#{nvinfo.id}/#{sname}") do
      upsert!(nvinfo, sname, nvinfo.bhash, force: force)
    end
  end

  def self.cache!(nvseed : Nvseed)
    CACHED.get("#{nvseed.nvinfo_id}/#{nvseed.sname}") { nvseed }
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, snvid : String, force = true)
    find({nvinfo_id: nvinfo.id, sname: sname}) || init!(nvinfo, sname, snvid)
  end

  def self.init!(nvinfo : Nvinfo, sname : String, snvid = nvinfo.bhash)
    model = new({nvinfo: nvinfo, sname: sname, snvid: snvid})
    model.zseed = SnameMap.zseed(sname)
    model.tap(&.save!)
  end
end
