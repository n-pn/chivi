require "./_base_view"

struct CV::ChinfoView
  include BaseView

  def initialize(@data : ChInfo, @full = true)
  end

  def to_json(jb : JSON::Builder)
    {
      chidx: @data.chidx,
      schid: @data.schid,

      title: @data.trans.title,
      chvol: @data.trans.chvol,
      uslug: @data.trans.uslug,

      utime: @data.stats.utime,
      chars: @data.stats.chars,
      parts: @data.stats.parts,
      uname: @data.stats.uname,

      sname: @data.proxy.try(&.sname),
    }.to_json(jb)
  end

  def self.list(list : Enumerable(ChInfo))
    list.map { |x| new(x) }
  end
end
