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

  column btitle : String = ""
  column author : String = ""

  column bcover : String = ""
  column bintro : String = ""
  column bgenre : String = ""

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  ##########

  column utime : Int64 = 0 # seed page update time as total seconds since the epoch
  column stime : Int64 = 0 # last crawled at

  column chap_count : Int32 = 0   # total chapters
  column last_schid : String = "" # seed's latest chap id

  timestamps

  def clink(schid : String) : String
    SiteLink.text_url(sname, snvid, schid)
  end

  # ------------------------

  def refresh!(force : Bool = false) : Nil
    self.stime = Time.utc.to_unix if force

    if sname == "=base"
      if force
        self.chap_count = 0
        self.last_schid = ""
        self.utime = 0_i64
      end

      self.init_base!(force: force, fetch: true)
    elsif self.remote?(force: force)
      self.remote_regen!(ttl: map_ttl(force: force), force: force)

      base_seed = Nvseed.load!(self.nvinfo, "=base")
      base_seed.clone_remote!(self)
      base_seed.reset_cache!
    else
      reset_cache! if force
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
      upsert!(nvinfo, sname, nvinfo.bhash, force: force)
    end
  end

  def self.load!(sname : String, snvid : String, force = false)
    unless nvseed = find({sname: sname, snvid: snvid})
      if nvinfo = Nvinfo.find({bhash: snvid})
        nvseed = init!(nvinfo, sname, snvid)
      else
        raise NotFound.new("Quyển sách không tồn tại (#{snvid})")
      end
    end

    CACHED.set("#{nvseed.nvinfo_id}/#{nvseed.sname}", nvseed)
    nvseed
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, snvid : String, force = true)
    find({nvinfo_id: nvinfo.id, sname: sname}) || init!(nvinfo, sname, snvid)
  end

  def self.init!(nvinfo : Nvinfo, sname : String, snvid = nvinfo.bhash)
    model = new({nvinfo: nvinfo, sname: sname, snvid: snvid})

    model.zseed = SnameMap.map_int(sname)
    model.init_base! if sname == "=base"

    model.tap(&.save!)
  end
end
