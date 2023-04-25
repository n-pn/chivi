module SiteLink
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
    "zxcs_me"  => "http://www.zxcs.info/post/%{bid}/",
    "biqugee"  => "https://www.biqugee.com/book/%{bid}/",
    "bxwxorg"  => "https://www.bxwxorg.com/read/%{bid}/",
    "zhwenpg"  => "https://novel.zhwenpg.com/b.php?id=%{bid}",
    "sdyfcm"   => "https://www.sdyfcm.com/%{bid}/",
    "jx_la"    => "https://www.jx.la/book/%{bid}/",
  }

  def info_url(sname : String, bid : Int32)
    INFOS.fetch(sname, "/") % {div: bid // 1000, bid: bid}
  end

  CATAS = {
    "69shu" => "https://www.69shu.com/%{bid}/",
    "ptwxz" => "https://www.ptwxz.com/html/%{div}/%{bid}/index.html",
  }

  def mulu_url(sname : String, bid : Int32)
    CATAS.fetch(sname) { INFOS.fetch(sname, "/") } % {div: bid // 1000, bid: bid}
  end

  CHAPS = {
    "!hetushu.com"  => "https://www.hetushu.com/book/%{bid}/%{cid}.html",
    "!69shu.com"    => "https://www.69shu.com/txt/%{bid}/%{cid}",
    "!xbiquge.so"   => "https://www.xbiquge.so/book/%{bid}/%{cid}.html",
    "!uukanshu.com" => "https://www.uukanshu.com/b/%{bid}/%{cid}.html",
    "!ptwxz.com"    => "https://www.ptwxz.com/html/%{div}/%{bid}/%{cid}.html",
    "!133txt.com"   => "https://www.133txt.com/xiaoshuo/%{bid}/%{cid}.html",
    "!bxwx.io"      => "https://www.bxwx.io/%{div}_%{bid}/%{cid}.html",
    "!b5200.org"    => "http://www.b5200.org/%{div}_%{bid}/%{cid}.html",
    "!paoshu8.com"  => "http://www.paoshu8.com/%{div}_%{bid}/%{cid}.html",
    "!biqu5200.net" => "http://www.biqu5200.net/%{div}_%{bid}/%{cid}.html",
    ###
    "!hetushu"  => "https://www.hetushu.com/book/%{bid}/%{cid}.html",
    "!69shu"    => "https://www.69shu.com/txt/%{bid}/%{cid}",
    "!xbiquge"  => "https://www.xbiquge.so/book/%{bid}/%{cid}.html",
    "!uukanshu" => "https://www.uukanshu.com/b/%{bid}/%{cid}.html",
    "!ptwxz"    => "https://www.ptwxz.com/html/%{div}/%{bid}/%{cid}.html",
    "!133txt"   => "https://www.133txt.com/xiaoshuo/%{bid}/%{cid}.html",
    "!bxwxio"   => "https://www.bxwx.io/%{div}_%{bid}/%{cid}.html",
    "!b5200"    => "http://www.b5200.org/%{div}_%{bid}/%{cid}.html",
    "!paoshu8"  => "http://www.paoshu8.com/%{div}_%{bid}/%{cid}.html",
    "!biqu5200" => "http://www.biqu5200.net/%{div}_%{bid}/%{cid}.html",
    # "!bqxs520.com" => "http://www.bqxs520.com/%{bid}/%{cid}.html",
    # "!uuks.org"     => "https://www.uuks.org/b/%{bid}/%{cid}.html",
    # "!biqugse.com" => "http://www.biqugse.com/%{bid}/%{cid}.html",
    "69shu"    => "https://www.69shu.com/txt/%{bid}/%{cid}",
    "uukanshu" => "https://www.uukanshu.com/b/%{bid}/%{cid}.html",
    "uuks"     => "https://www.uuks.org/b/%{bid}/%{cid}.html",
    "biqugse"  => "http://www.biqugse.com/%{bid}/%{cid}.html",
    "bqxs520"  => "http://www.bqxs520.com/%{bid}/%{cid}.html",
    "133txt"   => "https://www.133txt.com/xiaoshuo/%{bid}/%{cid}.html",
    "b5200"    => "http://www.b5200.org/%{div}_%{bid}/%{cid}.html",
    "bxwxio"   => "https://www.bxwx.io/%{div}_%{bid}/%{cid}.html",
    "xbiquge"  => "https://www.xbiquge.so/book/%{bid}/%{cid}.html",
    "yannuozw" => "http://www.yannuozw.com/yn/%{bid}/%{cid}.html",
    "kanshu8"  => "http://www.kanshu8.net/book/%{bid}/read_%{cid}.html",
    "ptwxz"    => "https://www.ptwxz.com/html/%{div}/%{bid}/%{cid}.html",
    "hetushu"  => "https://www.hetushu.com/book/%{bid}/%{cid}.html",
    "duokan8"  => "http://www.duokanba.com/%{div}_%{bid}/%{cid}.html",
    "rengshu"  => "http://www.rengshu.com/book/%{bid}/%{cid}",
    "paoshu8"  => "http://www.paoshu8.com/%{div}_%{bid}/%{cid}.html",
    "5200"     => "https://www.5200.tv/%{div}_%{bid}/%{cid}.html",
    "biqu5200" => "http://www.biqu5200.net/%{div}_%{bid}/%{cid}.html",
    "shubaow"  => "https://www.shubaow.net/%{div}_%{bid}/%{cid}.html",
    "bxwxorg"  => "https://www.bxwxorg.com/read/%{bid}/%{cid}.html",
    "biqugee"  => "https://www.biqugee.com/book/%{bid}/%{cid}.html",
    "zhwenpg"  => "https://novel.zhwenpg.com/r.php?id=%{cid}",
    "sdyfcm"   => "https://www.sdyfcm.com/%{bid}/%{cid}/",
    "jx_la"    => "https://www.jx.la/book/%{bid}/%{cid}.html",
  }

  def text_url(sname : String, bid : Int32, cid : Int32)
    return "" unless template = CHAPS[sname]?
    template % {div: bid // 1000, bid: bid, cid: cid}
  end
end
