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
  column zseed : Int32 { SnameMap.map_int(sname) }

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

    if sname == "union"
      if force
        self.chap_count = 0
        self.last_schid = ""
        self.utime = 0_i64
      end

      self.mirror_regen!(force: force, fetch: true)
    elsif self.remote?(force: force)
      self.remote_regen!(ttl: map_ttl(force: force), force: force)

      union_seed = Nvseed.load!(self.nvinfo, "union")
      union_seed.mirror_other!(self)
      union_seed.reset_cache!
    else
      reset_cache! if force
    end
  end
end
