require "./_base"

class CV::Nvdict
  include Clear::Model

  self.table = "nvdicts"
  primary_key

  belongs_to nvinfo : Nvinfo
  getter nvinfo : Nvinfo { Nvinfo.load!(self.nvinfo_id) }

  column dname : String
  column d_lbl : String

  column dsize : Int32 = 0
  column p_min : Int32 = 0

  column ctime : Int64 = 0_i64
  column utime : Int64 = 0_i64

  column unames : Array(String) = [] of String
  column themes : Array(String) = [] of String

  column parent_id : Int64 = -1
  column dupped_at : Int64 = -1

  timestamps

  #################

  # CACHE_STR = RamCache(String, self).new(2048)

  def self.load!(dname : String)
    self.find({dname: dname}) || self.init!(dname)
  end

  def self.init!(dname : String, vpdict = VpDict.load_novel(dname))
    raise "Invalid book: #{dname}" unless nvinfo = Nvinfo.find({bhash: dname})
    init!(nvinfo, vpdict)
  end

  def self.init!(nvinfo : Nvinfo, vpdict : VpDict)
    nvdict = new({
      nvinfo: nvinfo,
      dname:  nvinfo.bhash,
      d_lbl:  nvinfo.vname,
      dsize:  vpdict.size,
      ctime:  vpdict.list.find(&.mtime.> 10).try(&.utime) || 0_i64,
      utime:  vpdict.list.last?.try(&.utime) || 0_i64,
    })

    nvdict.tap(&.save!)
  end
end
