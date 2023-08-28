require "./_base_view"

struct CV::WnstemView
  include BaseView

  def initialize(@data : Wnstem, @full = false, @fresh = true)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "sname", @data.sname
      jb.field "snvid", @data.s_bid

      jb.field "chmax", @data.chap_count
      jb.field "utime", @data.utime

      jb.field "slink", @data.slink
      jb.field "stime", @data.stime

      if @full
        jb.field "fresh", @fresh

        jb.field "lasts", @data.last_chaps(4)
        jb.field "privi", @data.privi
        jb.field "cgift", @data.cgift
      end
    end
  end
end
