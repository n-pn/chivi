require "./_base_view"

struct CV::ChseedView
  include BaseView

  def initialize(@data : Nvseed)
  end

  def to_json(jb : JSON::Builder)
    {
      sname: @data.sname,
      snvid: @data.snvid,
      chaps: @data.chap_count,
      utime: @data.utime,
      stype: SnameMap.map_type(@data.sname),
      # atime: @data.atime,
      _link: SiteLink.info_url(@data.sname, @data.snvid),
    }.to_json(jb)
  end
end
