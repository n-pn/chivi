require "./_base_view"

struct CV::ChinfoView
  include BaseView

  def initialize(@data : Chinfo, @full = true)
  end

  def to_json(jb : JSON::Builder)
    {
      chidx: @data.chidx,
      schid: @data.schid,

      title: @data.trans.title,
      chvol: @data.trans.chvol,
      uslug: @data.trans.uslug,

      utime: @data.changed_at.try(&.to_unix) || 0_i64,
      chars: @data.w_count,
      parts: @data.p_count,
      uname: @data.viuser.try(&.uname),

      o_sname: "",
      o_snvid: "",
    }.to_json(jb)
  end

  def self.list(list : Enumerable(Chinfo))
    list.map { |x| new(x) }
  end
end
