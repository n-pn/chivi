require "./_base_view"

struct CV::ChinfoView
  include BaseView

  def initialize(@data : Chinfo, @full = true)
  end

  def to_json(jb : JSON::Builder)
    info = @data.mirror || @data

    {
      chidx: @data.chidx,
      schid: @data.schid,

      title: info.trans.title,
      chvol: info.trans.chvol,
      uslug: info.trans.uslug,

      utime: info.changed_at.try(&.to_unix) || 0_i64,
      chars: info.w_count,
      parts: info.p_count,
      uname: info.viuser.try(&.uname) || "?",

      sname: info.chroot.sname,
    }.to_json(jb)
  end

  def self.list(list : Enumerable(Chinfo))
    list.map { |x| new(x) }
  end
end
