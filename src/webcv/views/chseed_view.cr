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
      # atime: @data.atime,
      _link: site_link,
      _type: seed_type,
    }.to_json(jb)
  end

  def site_link
    SiteLink.binfo_url(@data.sname, @data.snvid)
  end

  def seed_type
    case @data.sname
    when "chivi"          then 0
    when "users", "local" then 1
    else
      NvSeed::REMOTES.includes?(@data.sname) ? 3 : 2
    end
  end
end
