module CV::SiteLink
  extend self

  # ameba:disable Metrics/CyclomaticComplexity
  def info_url(sname : String, s_bid : Int32)
    case sname
    when "69shu"    then "https://www.69shu.com/txt/#{s_bid}.htm"
    when "ptwxz"    then "https://www.ptwxz.com/bookinfo/#{group(s_bid, "/")}.html"
    when "uukanshu" then "https://www.uukanshu.com/b/#{s_bid}/"
    when "uuks"     then "https://www.uuks.org/b/#{s_bid}/"
    when "bxwxio"   then "https://www.bxwx.io/#{group(s_bid)}/"
    when "133txt"   then "https://www.133txt.com/book/#{s_bid}/"
    when "rengshu"  then "http://www.rengshu.com/book/#{s_bid}"
    when "biqugse"  then "http://www.biqugse.com/#{s_bid}/"
    when "bqxs520"  then "http://www.bqxs520.com/#{s_bid}/"
    when "yannuozw" then "http://www.yannuozw.com/yn/#{s_bid}.html"
    when "kanshu8"  then "http://www.kanshu8.net/book/#{s_bid}/"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{s_bid}/"
    when "biqu5200" then "http://www.biqu5200.net/#{group(s_bid)}/"
    when "hetushu"  then "https://www.hetushu.com/book/#{s_bid}/index.html"
    when "b5200"    then "http://www.b5200.org/#{group(s_bid)}/"
    when "5200"     then "https://www.5200.tv/#{group(s_bid)}/"
    when "paoshu8"  then "http://www.paoshu8.com/#{group(s_bid)}/"
    when "duokan8"  then "http://www.duokanba.com/#{group(s_bid)}/"
    when "shubaow"  then "https://www.shubaow.net/#{group(s_bid)}/"
    when "zxcs_me"  then "http://www.zxcs.me/post/#{s_bid}/"
    when "biqugee"  then "https://www.biqugee.com/book/#{s_bid}/"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{s_bid}/"
    when "zhwenpg"  then "https://novel.zhwenpg.com/b.php?id=#{s_bid}"
    when "sdyfcm"   then "https://www.sdyfcm.com/#{s_bid}/"
    when "jx_la"    then "https://www.jx.la/book/#{s_bid}/"
    else                 ""
    end
  end

  def mulu_url(sname : String, s_bid : Int32)
    case sname
    when "69shu" then "https://www.69shu.com/#{s_bid}/"
    when "ptwxz" then "https://www.ptwxz.com/html/#{group(s_bid, "/")}/index.html"
    else              info_url(sname, s_bid)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def text_url(sname : String, s_bid : Int32, s_cid : Int32)
    case sname
    when "69shu"    then "https://www.69shu.com/txt/#{s_bid}/#{s_cid}"
    when "uukanshu" then "https://www.uukanshu.com/b/#{s_bid}/#{s_cid}.html"
    when "uuks"     then "https://www.uuks.org/b/#{s_bid}/#{s_cid}.html"
    when "biqugse"  then "http://www.biqugse.com/#{s_bid}/#{s_cid}.html"
    when "bqxs520"  then "http://www.bqxs520.com/#{s_bid}/#{s_cid}.html"
    when "133txt"   then "https://www.133txt.com/xiaoshuo/#{s_bid}/#{s_cid}.html"
    when "b5200"    then "http://www.b5200.org/#{group(s_bid)}/#{s_cid}.html"
    when "bxwxio"   then "https://www.bxwx.io/#{group(s_bid)}/#{s_cid}.html"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{s_bid}/#{s_cid}.html"
    when "yannuozw" then "http://www.yannuozw.com/yn/#{s_bid}/#{s_cid}.html"
    when "kanshu8"  then "http://www.kanshu8.net/book/#{s_bid}/read_#{s_cid}.html"
    when "ptwxz"    then "https://www.ptwxz.com/html/#{group(s_bid, "/")}/#{s_cid}.html"
    when "hetushu"  then "https://www.hetushu.com/book/#{s_bid}/#{s_cid}.html"
    when "duokan8"  then "http://www.duokanba.com/#{group(s_bid)}/#{s_cid}.html"
    when "rengshu"  then "http://www.rengshu.com/book/#{s_bid}/#{s_cid}"
    when "paoshu8"  then "http://www.paoshu8.com/#{group(s_bid)}/#{s_cid}.html"
    when "5200"     then "https://www.5200.tv/#{group(s_bid)}/#{s_cid}.html"
    when "biqu5200" then "http://www.biqu5200.net/#{group(s_bid)}/#{s_cid}.html"
    when "shubaow"  then "https://www.shubaow.net/#{group(s_bid)}/#{s_cid}.html"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{s_bid}/#{s_cid}.html"
    when "biqugee"  then "https://www.biqugee.com/book/#{s_bid}/#{s_cid}.html"
    when "zhwenpg"  then "https://novel.zhwenpg.com/r.php?id=#{s_cid}"
    when "sdyfcm"   then "https://www.sdyfcm.com/#{s_bid}/#{s_cid}/"
    when "jx_la"    then "https://www.jx.la/book/#{s_bid}/#{s_cid}.html"
    else                 ""
    end
  end

  private def group(s_bid : Int32, sep = "_")
    "#{s_bid // 1000}#{sep}#{s_bid}"
  end
end
