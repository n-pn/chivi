require "../../_util/http_util"
require "../../_util/site_link"
require "../../_util/path_util"
require "../../_util/time_util"

require "./rm_info/*"
require "../nvinfo/seed_util"

class CV::RmInfo
  def self.mkdir!(sname : String)
    FileUtils.mkdir_p("_db/.cache/#{sname}/infos")
  end

  TTL = 1.years
  @parser : RmInfoGeneric

  def initialize(@sname : String, @snvid : String, ttl = TTL, lbl = "1/1")
    @dir = "_db/.cache/#{@sname}/infos"
    ttl = 10.years if SeedUtil.map_type(@sname) < 3
    @encoding = HttpUtil.encoding_for(@sname)
    @parser = load_parser(ttl, lbl)
  end

  def load_parser(ttl = TTL, lbl = "1/1")
    ihtml = load_info_html(ttl: ttl, lbl: lbl)

    case @sname
    when "hetushu" then RmInfoHetushu.new(ihtml)
    when "zhwenpg" then RmInfoZhwenpg.new(ihtml)
    when "bxwxorg" then RmInfoBxwxorg.new(ihtml)
    when "ptwxz"   then RmInfoPtwxz.new(ihtml, load_mulu_html(ttl, lbl))
    when "69shu"   then RmInfo69shu.new(ihtml, load_mulu_html(ttl, lbl), @snvid)
    else                RmInfoGeneric.new(ihtml)
    end
  end

  def load_info_html(ttl = TTL, lbl = "1/1")
    file = "#{@dir}/#{@snvid}.html.gz"

    GzipFile.new(file).read(ttl) do
      url = SiteLink.info_url(@sname, @snvid)
      HttpUtil.get_html(url, encoding: @encoding, lbl: lbl)
    end
  end

  def load_mulu_html(ttl = TTL, lbl = "1/1")
    file = "#{@dir}/#{@snvid}-mulu.html.gz"

    GzipFile.new(file).read(ttl) do
      url = SiteLink.mulu_url(@sname, @snvid)
      HttpUtil.get_html(url, encoding: @encoding, lbl: lbl)
    end
  end

  getter btitle : String { @parser.btitle }
  getter author : String { @parser.author }
  getter genres : Array(String) { @parser.genres }
  getter bintro : Array(String) { @parser.bintro }
  getter bcover : String { @parser.bcover }

  getter status : Tuple(Int32, String) { @parser.status }
  getter update : Tuple(Int64, String) do
    updated_at, update_str = @parser.update
    {updated_at.to_unix, update_str}
  end

  getter last_schid : String { @parser.last_schid }

  getter chap_infos : Array(ChInfo) do
    case @sname
    when "duokan8" then @parser.extract_chapters_plain(".chapter-list a")
    when "5200"    then @parser.extract_chapters_chvol(".listmain > dl")
    else                @parser.chapters
    end
  end
end
