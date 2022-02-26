require "./_base_view"

struct CV::ChseedView
  include BaseView

  def initialize(@data : Zhbook)
  end

  def to_json(jb : JSON::Builder)
    {
      sname: @data.sname,
      snvid: @data.snvid,
      chaps: @data.chap_count,
      utime: @data.utime,
      stype: NvSeed.map_type(@data.sname),
      # atime: @data.atime,
      _link: site_link,
    }.to_json(jb)
  end

  def site_link
    SiteLink.binfo_url(@data.sname, @data.snvid)
  end
end
