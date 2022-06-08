require "../../../libcv/qtran_data"

class CV::QtranData
  getter simps : Array(String) do
    @input.map { |x| MtCore.trad_to_simp(x) }
  end

  def make_engine(uname : String) : MtCore
    MtCore.generic_mtl(@dname, uname)
  end

  ##########

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
end
