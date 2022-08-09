require "./_base_view"

struct CV::ChinfoView
  include BaseView

  def initialize(@data : ChInfo2, @full = true)
  end

  def to_json(jb : JSON::Builder)
    trans = @data.trans

    {
      sname: @data.sname,
      chidx: @data.ch_no,
      schid: @data.s_cid,

      title: trans.title,
      chvol: trans.chvol,
      uslug: trans.uslug,

      utime: @data.utime,
      chars: @data.c_len,
      parts: @data.p_len,
      uname: @data.uname,
    }.to_json(jb)
  end

  def self.list(list : Enumerable(ChInfo2))
    list.map { |x| new(x) }
  end
end
