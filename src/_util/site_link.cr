module CV::SiteLink
  extend self

  INFOS = {
    "69shu"    => "https://www.69shu.com/txt/%{bid}.htm",
    "ptwxz"    => "https://www.ptwxz.com/bookinfo/%{div}/%{bid}.html",
    "uukanshu" => "https://www.uukanshu.com/b/%{bid}/",
    "uuks"     => "https://www.uuks.org/b/%{bid}/",
    "bxwxio"   => "https://www.bxwx.io/%{div}_%{bid}/",
    "133txt"   => "https://www.133txt.com/book/%{bid}/",
    "rengshu"  => "http://www.rengshu.com/book/%{bid}",
    "biqugse"  => "http://www.biqugse.com/%{bid}/",
    "bqxs520"  => "http://www.bqxs520.com/%{bid}/",
    "yannuozw" => "http://www.yannuozw.com/yn/%{bid}.html",
    "kanshu8"  => "http://www.kanshu8.net/book/%{bid}/",
    "xbiquge"  => "https://www.xbiquge.so/book/%{bid}/",
    "biqu5200" => "http://www.biqu5200.net/%{div}_%{bid}/",
    "hetushu"  => "https://www.hetushu.com/book/%{bid}/index.html",
    "b5200"    => "http://www.b5200.org/%{div}_%{bid}/",
    "5200"     => "https://www.5200.tv/%{div}_%{bid}/",
    "paoshu8"  => "http://www.paoshu8.com/%{div}_%{bid}/",
    "duokan8"  => "http://www.duokanba.com/%{div}_%{bid}/",
    "shubaow"  => "https://www.shubaow.net/%{div}_%{bid}/",
    "zxcs_me"  => "http://www.zxcs.me/post/%{bid}/",
    "biqugee"  => "https://www.biqugee.com/book/%{bid}/",
    "bxwxorg"  => "https://www.bxwxorg.com/read/%{bid}/",
    "zhwenpg"  => "https://novel.zhwenpg.com/b.php?id=%{bid}",
    "sdyfcm"   => "https://www.sdyfcm.com/%{bid}/",
    "jx_la"    => "https://www.jx.la/book/%{bid}/",
  }

  def info_url(sname : String, bid : Int32)
    INFOS[sname]?.try(&.%({div: bid // 100, bid: bid})) || ""
  end

  def mulu_url(sname : String, bid : Int32)
    case sname
    when "69shu" then "https://www.69shu.com/%{bid}/"
    when "ptwxz" then "https://www.ptwxz.com/html/%{div}/%{bid}/index.html"
    else              info_url(sname, bid)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def text_url(sname : String, bid : Int32, cid : Int32)
    case sname
    when "69shu"    then "https://www.69shu.com/txt/%{bid}/%{cid}"
    when "uukanshu" then "https://www.uukanshu.com/b/%{bid}/%{cid}.html"
    when "uuks"     then "https://www.uuks.org/b/%{bid}/%{cid}.html"
    when "biqugse"  then "http://www.biqugse.com/%{bid}/%{cid}.html"
    when "bqxs520"  then "http://www.bqxs520.com/%{bid}/%{cid}.html"
    when "133txt"   then "https://www.133txt.com/xiaoshuo/%{bid}/%{cid}.html"
    when "b5200"    then "http://www.b5200.org/%{div}_%{bid}/%{cid}.html"
    when "bxwxio"   then "https://www.bxwx.io/%{div}_%{bid}/%{cid}.html"
    when "xbiquge"  then "https://www.xbiquge.so/book/%{bid}/%{cid}.html"
    when "yannuozw" then "http://www.yannuozw.com/yn/%{bid}/%{cid}.html"
    when "kanshu8"  then "http://www.kanshu8.net/book/%{bid}/read_%{cid}.html"
    when "ptwxz"    then "https://www.ptwxz.com/html/%{div}/%{bid}/%{cid}.html"
    when "hetushu"  then "https://www.hetushu.com/book/%{bid}/%{cid}.html"
    when "duokan8"  then "http://www.duokanba.com/%{div}_%{bid}/%{cid}.html"
    when "rengshu"  then "http://www.rengshu.com/book/%{bid}/%{cid}"
    when "paoshu8"  then "http://www.paoshu8.com/%{div}_%{bid}/%{cid}.html"
    when "5200"     then "https://www.5200.tv/%{div}_%{bid}/%{cid}.html"
    when "biqu5200" then "http://www.biqu5200.net/%{div}_%{bid}/%{cid}.html"
    when "shubaow"  then "https://www.shubaow.net/%{div}_%{bid}/%{cid}.html"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/%{bid}/%{cid}.html"
    when "biqugee"  then "https://www.biqugee.com/book/%{bid}/%{cid}.html"
    when "zhwenpg"  then "https://novel.zhwenpg.com/r.php?id=%{cid}"
    when "sdyfcm"   then "https://www.sdyfcm.com/%{bid}/%{cid}/"
    when "jx_la"    then "https://www.jx.la/book/%{bid}/%{cid}.html"
    else                 ""
    end
  end

  private def div(bid : Int32, sep = "_")
    "#{bid // 1000}#{sep}%{bid}"
  end
end
