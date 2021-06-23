require "../../../src/seeds/rm_info"

module CV::SeedUtil
  extend self

  def get_mtime(file : String) : Int64
    File.info?(file).try(&.modification_time.to_unix) || 0_i64
  end

  def last_snvid(sname : String) : String
    file = "_db/.cache/#{sname}/index.html.gz"
    encoding = HttpUtils.encoding_for(sname)
    html = HttpUtils.load_html(index_link(sname), file, ttl: 12.hours, encoding: encoding)

    page = HtmlParser.new(html)

    case sname
    when "69shu"
      href = page.attr(".ranking:nth-child(2) a:first-of-type", "href")
      File.basename(href, ".htm")
    when "hetushu"
      href = page.attr("#list a:first-of-type", "href")
      File.basename(File.dirname(href))
    when "nofff"
      href = page.attr("#newscontent_n .s2 > a", "href")
      File.basename(href)
    when "rengshu", "xbiquge", "biqubao", "bxwxorg"
      href = page.attr("#newscontent > .r .s2 > a", "href")
      File.basename(href)
    when "bqg_5200", "paoshu8", "shubaow"
      href = page.attr("#newscontent > .r .s2 > a", "href")
      File.basename(href).split("_").last
    when "5200"
      href = page.attr(".up > .r .s2 > a", "href")
      File.basename(href).split("_").last
    when "duokan8"
      href = page.attr(".recommend-list ul:not([class]) a:first-of-type", "href")
      File.basename(href).split("_").last
    else
      raise "Unsupported source name!"
    end
  end

  def index_link(sname : String) : String
    case sname
    when "69shu"    then "https://www.69shu.com/"
    when "hetushu"  then "https://www.hetushu.com/book/index.php"
    when "rengshu"  then "http://www.rengshu.com/"
    when "xbiquge"  then "https://www.xbiquge.so/"
    when "biqubao"  then "https://www.biqubao.com/"
    when "5200"     then "https://www.5200.tv/"
    when "duokan8"  then "http://www.duokan8.com/"
    when "nofff"    then "https://www.nofff.com/"
    when "bqg_5200" then "https://www.biquge5200.com/"
    when "bxwxorg"  then "https://www.bxwxorg.com/"
    when "shubaow"  then "https://www.shubaow.net/"
    when "paoshu8"  then "http://www.paoshu8.com/"
    else                 raise "Unsupported source name!"
    end
  end

  def max_threads(sname : String)
    case sname
    when "zhwenpg", "shubaow"           then 1
    when "paoshu8", "69shu", "bqg_5200" then 3
    when "hetushu", "duokan8"           then 6
    else                                     10
    end
  end

  def sleep_time(sname : String)
    case sname
    when "shubaow"  then Random.rand(1000..2000).milliseconds
    when "zhwenpg"  then Random.rand(500..1000).milliseconds
    when "bqg_5200" then Random.rand(100..500).milliseconds
    else                 Random.rand(10..50).milliseconds
    end
  end
end

# puts CV::SeedUtil.last_snvid("69shu")
