module CV::SiteLink
  extend self

  # ameba:disable Metrics/CyclomaticComplexity
  def info_url(sname : String, snvid : String)
    case sname
    when "sdyfcm"   then "https://www.sdyfcm.com/#{snvid}/"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{snvid}.htm"
    when "zxcs_me"  then "http://www.zxcs.me/post/#{snvid}/"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{snvid}/"
    when "biqugee"  then "https://www.biqugee.com/book/#{snvid}/"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{snvid}/"
    when "zhwenpg"  then "https://novel.zhwenpg.com/b.php?id=#{snvid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/index.html"
    when "duokan8"  then "http://www.duokanba.com/#{group(snvid)}/"
    when "paoshu8"  then "http://www.paoshu8.com/#{group(snvid)}/"
    when "5200"     then "https://www.5200.tv/#{group(snvid)}/"
    when "shubaow"  then "https://www.shubaow.net/#{group(snvid)}/"
    when "biqu5200" then "http://www.biqu5200.net/#{group(snvid)}/"
    when "ptwxz"    then "https://www.ptwxz.com/bookinfo/#{group(snvid, "/")}.html"
    when "uukanshu" then "https://www.uukanshu.com/b/#{snvid}/"
    when "133txt"   then "https://www.133txt.com/book/#{snvid}/"
    when "biqugse"  then "http://www.biqugse.com/#{snvid}/"
    when "bqxs520"  then "http://www.bqxs520.com/#{snvid}/"
    when "b5200"    then "http://www.b5200.org/#{group(snvid)}/"
    else                 "/"
    end
  end

  def mulu_url(sname : String, snvid : String)
    case sname
    when "69shu" then "https://www.69shu.com/#{snvid}/"
    when "ptwxz" then "https://www.ptwxz.com/html/#{group(snvid, "/")}/index.html"
    else              info_url(sname, snvid)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def text_url(sname : String, snvid : String, schid : String)
    case sname
    when "sdyfcm"   then "https://www.sdyfcm.com/#{snvid}/#{schid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{snvid}/#{schid}"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/#{schid}.html"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}/#{schid}"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{snvid}/#{schid}.html"
    when "biqugee"  then "https://www.biqugee.com/book/#{snvid}/#{schid}.html"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{snvid}/#{schid}.html"
    when "zhwenpg"  then "https://novel.zhwenpg.com/r.php?id=#{schid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/#{schid}.html"
    when "duokan8"  then "http://www.duokanba.com/#{group(snvid)}/#{schid}.html"
    when "paoshu8"  then "http://www.paoshu8.com/#{group(snvid)}/#{schid}.html"
    when "5200"     then "https://www.5200.tv/#{group(snvid)}/#{schid}.html"
    when "shubaow"  then "https://www.shubaow.net/#{group(snvid)}/#{schid}.html"
    when "biqu5200" then "http://www.biqu5200.net/#{group(snvid)}/#{schid}.html"
    when "ptwxz"    then "https://www.ptwxz.com/html/#{group(snvid, "/")}/#{schid}.html"
    when "uukanshu" then "https://www.uukanshu.com/b/#{snvid}/#{schid}.html"
    when "133txt"   then "https://www.133txt.com/xiaoshuo/#{snvid}/#{schid}.html"
    when "biqugse"  then "http://www.biqugse.com/#{snvid}/#{schid}.html"
    when "bqxs520"  then "http://www.bqxs520.com/#{snvid}/#{schid}.html"
    when "b5200"    then "http://www.b5200.org/#{group(snvid)}/#{schid}.html"
    else                 "/"
    end
  end

  private def group(snvid : String, sep = "_")
    "#{snvid.to_i // 1000}#{sep}#{snvid}"
  end
end
