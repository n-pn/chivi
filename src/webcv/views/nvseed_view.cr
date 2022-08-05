require "./_base_view"

struct CV::ChrootView
  include BaseView

  def initialize(@data : Chroot, @full = false, @fresh = true)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "sname", @data.sname
      jb.field "snvid", @data.s_bid

      jb.field "chmax", @data.chap_count
      jb.field "utime", @data.utime

      jb.field "stype", SnameMap.map_type(@data.sname)
      jb.field "slink", SiteLink.info_url(@data.sname, @data.s_bid)

      if @full
        jb.field "stime", @data.stime
        jb.field "fresh", @fresh

        jb.field "lasts" do
          jb.array do
            ChinfoView.list(@data.lastpg).each(&.to_json(jb))
          end
        end

        jb.field "free_chap", @data.free_chap
        jb.field "privi_map", @data.privi_map
      end
    end
  end
end
