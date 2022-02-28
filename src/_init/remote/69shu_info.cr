require "./generic_info"

class CV::RmInfo69shu < CV::RmInfoGeneric
  def initialize(info_html : String, mulu_html : String? = nil, @snvid : String = "")
    @info = HtmlParser.new(info_html)
    @mulu = mulu_html ? HtmlParser.new(mulu_html) : @info
  end

  def btitle : String
    @info.text("h1 > a") { @info.text(".weizhi > a:last-child") }
  end

  def author : String
    @info.text(".booknav2 > p:nth-child(2) > a") { @info.text(".mu_beizhu > a[target]") }
  end

  def genres : Array(String)
    sel_1 = ".booknav2 > p:nth-child(3) > a"
    sel_2 = ".weizhi > a:nth-child(2)"
    [@info.text(sel_1) { @info.text(sel_2) }]
  end

  def bintro : Array(String)
    @info.text_para(".navtxt > p:first-child")
  end

  def bcover : String
    href = "/#{@snvid.to_i // 1000}/#{@snvid}/#{@snvid}s.jpg"
    "https://www.69shu.com/files/article/image/#{href}"
  end

  def status_str : String
    @info.text(".booknav2 > p:nth-child(4)").split("  |  ").last
  end

  def update_str : String
    @info.text(".booknav2 > p:nth-child(5)").sub("更新：", "")
  end

  def updated_at(update_str = self.update_str) : Time
    fix_update(super(update_str))
  end

  def extract_schid(href : String)
    File.basename(href)
  end

  def last_schid_href : String
    @info.attr(".qustime a:first-child", "href")
  end

  def chapters
    extract_chapters_plain("#catalog li > a")
  end
end
