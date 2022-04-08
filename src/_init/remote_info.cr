require "../_util/http_util"
require "../_util/site_link"
require "../_util/path_util"
require "../_util/time_util"

require "./remote/*"

class CV::RemoteInfo
  DIR = "_db/.cache/%s/infos"
  TTL = 10.years

  getter dir : String
  @ttl : Time::Span | Time::MonthSpan

  def initialize(@sname : String, @snvid : String, @ttl = TTL, @lbl = "1/1")
    @dir = DIR % @sname
    @ttl = 10.years if SnameMap.map_type(@sname) < 3
    @encoding = HttpUtil.encoding_for(@sname)
  end

  getter parser : RmInfoGeneric { get_parser(full: true) }
  forward_missing_to parser

  def get_parser(full = false)
    info = self.info_html

    case @sname
    when "hetushu" then RmInfoHetushu.new(info, nil)
    when "zhwenpg" then RmInfoZhwenpg.new(info, nil)
    when "bxwxorg" then RmInfoBxwxorg.new(info, nil)
    when "ptwxz"   then RmInfoPtwxz.new(info, full ? self.mulu_html : nil)
    when "69shu"   then RmInfo69shu.new(info, full ? self.mulu_html : nil, @snvid)
    else                RmInfoGeneric.new(info, nil)
    end
  end

  def info_html
    file = "#{@dir}/#{@snvid}.html.gz"

    GzipFile.new(file).read(@ttl) do
      url = SiteLink.info_url(@sname, @snvid)
      HttpUtil.get_html(url, encoding: @encoding, lbl: @lbl)
    end
  end

  def mulu_html
    file = "#{@dir}/#{@snvid}-mulu.html.gz"

    GzipFile.new(file).read(@ttl) do
      url = SiteLink.mulu_url(@sname, @snvid)
      HttpUtil.get_html(url, encoding: @encoding, lbl: @lbl)
    end
  end

  getter update : Tuple(Int64, String) do
    updated_at, update_str = parser.update
    {updated_at.to_unix, update_str}
  end

  getter chap_infos : Array(ChInfo) do
    case @sname
    when "duokan8" then parser.extract_chapters_plain(".chapter-list a")
    when "5200"    then parser.extract_chapters_chvol(".listmain > dl")
    else                parser.chapters
    end
  end
end
