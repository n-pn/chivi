module CV::SiteLink
  extend self

  def index_url(sname : String)
    case sname
    when "hetushu"  then "https://www.hetushu.com/book/index.php"
    when "rengshu"  then "http://www.rengshu.com/"
    when "xbiquge"  then "https://www.xbiquge.so/"
    when "biqubao"  then "https://www.biqugee.com/"
    when "5200"     then "https://www.5200.tv/"
    when "duokan8"  then "http://www.duokan8.com/"
    when "nofff"    then "https://www.nofff.com/"
    when "bqg_5200" then "http://www.biquge5200.net/"
    when "bxwxorg"  then "https://www.bxwxorg.com/"
    when "shubaow"  then "https://www.shubaow.net/"
    when "paoshu8"  then "http://www.paoshu8.com/"
    else                 raise "Unsupported source name!"
    end
  end

  def binfo_url(sname : String, snvid : String)
    case sname
    when "nofff"    then "https://www.nofff.com/#{snvid}/"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/"
    when "qu_la"    then "https://www.qu.la/book/#{snvid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{snvid}.htm"
    when "zxcs_me"  then "http://www.zxcs.me/post/#{snvid}/"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{snvid}/"
    when "biqubao"  then "https://www.biqugee.com/book/#{snvid}/"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{snvid}/"
    when "zhwenpg"  then "https://novel.zhwenpg.com/b.php?id=#{snvid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/index.html"
    when "duokan8"  then "http://www.duokanb.com/#{group(snvid)}/"
    when "paoshu8"  then "http://www.paoshu8.com/#{group(snvid)}/"
    when "5200"     then "https://www.5200.tv/#{group(snvid)}/"
    when "shubaow"  then "https://www.shubaow.net/#{group(snvid)}/"
    when "bqg_5200" then "http://www.biquge5200.net/#{group(snvid)}/"
    when "ptwxz"    then "https://www.ptwxz.com/bookinfo/#{group(snvid, "/")}.html"
    else                 "/"
    end
  end

  def chidx_url(sname : String, snvid : String)
    case sname
    when "69shu" then "https://www.69shu.com/#{snvid}/"
    when "ptwxz" then "https://www.ptwxz.com/html/#{group(snvid, "/")}/index.html"
    else              binfo_url(sname, snvid)
    end
  end

  def chtxt_url(sname : String, snvid : String, schid : String)
    case sname
    when "nofff"    then "https://www.nofff.com/#{snvid}/#{schid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{snvid}/#{schid}"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/#{schid}.html"
    when "qu_la"    then "https://www.qu.la/book/#{snvid}/#{schid}.html"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}/#{schid}"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{snvid}/#{schid}.html"
    when "biqubao"  then "https://www.biqugee.com/book/#{snvid}/#{schid}.html"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{snvid}/#{schid}.html"
    when "zhwenpg"  then "https://novel.zhwenpg.com/r.php?id=#{schid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/#{schid}.html"
    when "duokan8"  then "http://www.duokanb.com/#{group(snvid)}/#{schid}.html"
    when "paoshu8"  then "http://www.paoshu8.com/#{group(snvid)}/#{schid}.html"
    when "5200"     then "https://www.5200.tv/#{group(snvid)}/#{schid}.html"
    when "shubaow"  then "https://www.shubaow.net/#{group(snvid)}/#{schid}.html"
    when "bqg_5200" then "http://www.biquge5200.net/#{group(snvid)}/#{schid}.html"
    when "ptwxz"    then "https://www.ptwxz.com/html/#{group(snvid, "/")}/#{schid}.html"
    else                 "/"
    end
  end

  private def group(snvid : String, sep = "_")
    "#{snvid.to_i // 1000}#{sep}#{snvid}"
  end
end
