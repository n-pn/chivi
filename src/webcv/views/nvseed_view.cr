require "./_base_view"

struct CV::NvseedView
  include BaseView

  def initialize(@data : Nvseed, @full = false, @fresh = true)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "sname", @data.sname
      jb.field "zseed", @data.zseed
      jb.field "snvid", @data.snvid

      jb.field "chaps", @data.chap_count
      jb.field "utime", @data.utime

      jb.field "stype", SnameMap.map_type(@data.sname)
      jb.field "slink", SiteLink.info_url(@data.sname, @data.snvid)

      if @full
        jb.field "stime", @data.stime
        jb.field "fresh", @fresh

        jb.field "lasts" do
          jb.array do
            @data.lastpg.each { |x| ChinfoView.new(x).to_json(jb) }
          end
        end
      end
    end
  end
end
