require "./_base_view"

struct CV::ChinfoView
  include BaseView

  def initialize(@data : Chinfo, @full = true)
  end

  def to_json(jb : JSON::Builder)
    {
      chidx: @data.chidx,
      schid: @data.schid,

      title: @data.vi_title.empty? ? "Thiếu tựa" : @data.vi_title,
      chvol: @data.vi_chvol.empty? ? "Chính văn" : @data.vi_chvol,
      uslug: @data.url_slug,

      utime: @data.changed_at.try(&.to_unix) || 0_i64,
      chars: @data.w_count,
      parts: @data.p_count,
      uname: @data.viuser.try(&.uname) || "?",

      sname: @data.chroot.sname,
    }.to_json(jb)
  end

  def self.list(list : Enumerable(Chinfo))
    list.map { |x| new(x.mirror || x) }
  end
end
