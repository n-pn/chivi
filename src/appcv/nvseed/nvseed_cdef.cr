# add more class methods to Nvseed class

class CV::Nvseed
  SEED_CACHE = RamCache(Int64, self).new(1024)

  def self.load!(nvinfo_id : Int64, zseed : Int32) : self
    load!(Nvinfo.load!(nvinfo_id), zseed)
  end

  def self.load!(nvinfo : Nvinfo, sname : String) : self
    load!(nvinfo, SnameMap.map_int(sname))
  end

  def self.load!(nvinfo : Nvinfo, zseed : Int32) : self
    SEED_CACHE.get(SnameMap.map_uid(nvinfo.id, zseed)) do
      find(nvinfo.id, zseed) || init!(nvinfo, zseed)
    end
  end

  def self.init!(nvinfo : Nvinfo, zseed : Int32, fetch : Bool = false)
    case zseed
    when  0 then init!(nvinfo, "union").tap(&.mirror_regen!(fetch: fetch))
    when 63 then init!(nvinfo, "users") # TODO: check folder and recover
    else         raise "Source #{zseed} not found!"
    end
  end

  def self.init!(nvinfo : Nvinfo, sname : String, snvid = nvinfo.bhash)
    zseed = SnameMap.map_int(sname)
    model = new({nvinfo: nvinfo, zseed: zseed, sname: sname, snvid: snvid})
    model.uid = SnameMap.map_uid(nvinfo.id, zseed)
    model.tap(&.save!)
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, snvid : String)
    find(nvinfo.id, sname) || init!(nvinfo, sname, snvid)
  end

  def self.find(nvinfo_id : Int64, sname : String)
    zseed = SnameMap.map_int(sname)
    find({uid: SnameMap.map_uid(nvinfo_id, zseed)})
  end

  def self.find(nvinfo_id : Int64, zseed : Int32)
    find({uid: SnameMap.map_uid(nvinfo_id, zseed)})
  end
end
