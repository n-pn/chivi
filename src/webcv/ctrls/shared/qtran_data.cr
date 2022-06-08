require "../../../libcv/qtran_data"

class CV::QtranData < Libcv::QtranData
  getter simps : Array(String) { @input.map { |x| MtCore.trad_to_simp(x) } }

  CACHE = RamCache(String, self).new(2048, 2.hours)

  def make_engine(uname : String)
    MtCore.generic_mtl(@dname, uname)
  end

  def self.load!(ukey : String, type = "chaps")
    CACHE.get("#{type}--#{ukey}") do
      file = path(ukey, type)
      load(file) || yield.tap(&.save!(file))
    end
  end

  def self.get_d_lbl(dname : String)
    return "Tổng hợp" unless dname[0]? == '-'
    return "Không rõ" unless nvinfo = Nvinfo.find({bhash: dname[1..]})
    nvinfo.vname
  end

  def self.nvchap(lines, nvinfo, stats, cpart)
    dname = nvinfo.dname
    d_lbl = nvinfo.vname

    parts = stats.parts
    label = parts > 1 ? " [#{cpart + 1}/#{parts}]" : ""
    new(lines, dname, d_lbl, label: label)
  end

  def self.delete_nvchap(seed_id : Int64, chidx : Int32, parts = 1)
    parts.times do |cpart|
      ukey = nvchap_ukey(seed_id, chidx, cpart)
      CACHE.delete("chaps--#{ukey}")
      file = path(ukey, "chaps")

      File.delete(file) if File.exists?(file)
    end
  end
end
