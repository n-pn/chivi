require "myhtml"
require "colorize"
require "file_utils"

require "../_utils/http_utils"
require "../_utils/file_utils"

module CV::RmSpider
  extend self

  def fetch(file : String, link : String, sname : String, ttl = 1.week)
    expiry = sname == "jx_la" ? Time.utc(2010, 1, 1) : Time.utc - ttl

    unless html = FileUtils.read(file, expiry)
      html = HttpUtils.get_html(link, encoding: encoding_for(sname))

      ::FileUtils.mkdir_p(File.dirname(file))
      File.write(file, html)
    end

    html
  end

  def encoding_for(sname : String) : String
    case sname
    when "jx_la", "hetushu", "paoshu8", "zhwenpg", "zxcs_me"
      "UTF-8"
    else
      "GBK"
    end
  end

  def nvinfo_file(sname : String, snvid : String)
    "_db/.cache/#{sname}/infos/#{snvid}.html"
  end

  def chinfo_file(sname : String, snvid : String)
    # TODO: update for 69shu
    "_db/.cache/#{sname}/infos/#{snvid}.html"
  end

  def chtext_file(sname : String, snvid : String, schid : String)
    "_db/.cache/#{sname}/texts/#{snvid}/#{schid}.html"
  end

  def nvinfo_link(sname : String, snvid : String) : String
    case sname
    when "nofff"    then "https://www.nofff.com/#{snvid}/"
    when "69shu"    then "https://www.69shu.com/#{snvid}/"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/"
    when "qu_la"    then "https://www.qu.la/book/#{snvid}/"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}"
    when "xbiquge"  then "https://www.xbiquge.cc/book/#{snvid}/"
    when "zhwenpg"  then "https://novel.zhwenpg.com/b.php?id=#{snvid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/index.html"
    when "duokan8"  then "http://www.duokanba.info/#{scoped(snvid)}/"
    when "paoshu8"  then "http://www.paoshu8.com/#{scoped(snvid)}/"
    when "5200"     then "https://www.5200.tv/#{scoped(snvid)}/"
    when "shubaow"  then "https://www.shubaow.net/#{scoped(snvid)}/"
    when "bqg_5200" then "https://www.biquge5200.com/#{scoped(snvid)}/"
    else                 raise "Unsupported remote source <#{sname}>!"
    end
  end

  def chinfo_link(sname : String, snvid : String) : String
    # TODO: update for 69shu
    nvinfo_link(sname, snvid)
  end

  def chtext_link(sname : String, snvid : String, schid : String) : String
    case sname
    when "nofff"    then "https://www.nofff.com/#{snvid}/#{schid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{snvid}/#{schid}"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/#{schid}.html"
    when "qu_la"    then "https://www.qu.la/book/#{snvid}/#{schid}.html"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}/#{schid}"
    when "xbiquge"  then "https://www.xbiquge.cc/book/#{snvid}/#{schid}.html"
    when "zhwenpg"  then "https://novel.zhwenpg.com/r.php?id=#{schid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/#{schid}.html"
    when "duokan8"  then "http://www.duokanba.info/#{scoped(snvid)}/#{schid}.html"
    when "paoshu8"  then "http://www.paoshu8.com/#{scoped(snvid)}/#{schid}.html"
    when "5200"     then "https://www.5200.tv/#{scoped(snvid)}/#{schid}.html"
    when "shubaow"  then "https://www.shubaow.net/#{scoped(snvid)}/#{schid}.html"
    when "bqg_5200" then "https://www.biquge5200.com/#{scoped(snvid)}/#{schid}.html"
    else
      raise "Unsupported remote source <#{sname}>!"
    end
  end

  private def scoped(snvid : String)
    "#{snvid.to_i // 1000}_#{snvid}"
  end
end
