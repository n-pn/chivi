# add more class methods to Nvseed class

class CV::Nvseed
  SEED_CACHE = RamCache(String, self).new(1024)

  def self.load!(nvinfo_id : Int64, sname : String, force = false)
    raise "Quyển sách không tồn tại" unless nvinfo = Nvinfo.load!(nvinfo_id)
    load!(nvinfo, sname, force: force)
  end

  def self.load!(nvinfo : Nvinfo, sname : String, force = false) : self
    SEED_CACHE.get("#{nvinfo.id}-#{sname}") do
      upsert!(nvinfo, sname, nvinfo.bhash, force: force)
    end
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, snvid : String, force = true)
    find({nvinfo_id: nvinfo.id, sname: sname}) || begin
      raise "Source #{sname} not found!" unless force

      model = new({nvinfo: nvinfo, sname: sname, snvid: snvid}).tap(&.save!)
      model.mirror_regen! if sname == "nuion"

      model
    end
  end
end
