require "../wn_seed"

MAP = {
  "!hetushu.com"  => "https://www.hetushu.com/book/%{bid}/index.html",
  "!69shu.com"    => "https://www.69shu.com/%{bid}/",
  "!xbiquge.bz"   => "https://www.xbiquge.bz/book/%{bid}/",
  "!ptwxz.com"    => "https://www.ptwxz.com/html/%{div}/%{bid}/index.html",
  "!uukanshu.com" => "https://www.uukanshu.com/b/%{bid}/",
  # "!uuks.org"     => "https://www.uuks.org/b/%{bid}/",
  "!bxwx.io"    => "https://www.bxwx.io/%{div}_%{bid}/",
  "!133txt.com" => "https://www.133txt.com/book/%{bid}/",
  # "!rengshu.com"  => "http://www.rengshu.com/book/%{bid}",
  "!biqugse.com" => "http://www.biqugse.com/%{bid}/",
  # "!bqxs520.com"  => "http://www.bqxs520.com/%{bid}/",
  "!yannuozw.com" => "http://www.yannuozw.com/yn/%{bid}.html",
  # "!kanshu8.net"  => "http://www.kanshu8.net/book/%{bid}/",
  "!biqu5200.net" => "http://www.biqu5200.net/%{div}_%{bid}/",
  "!b5200.org"    => "http://www.b5200.org/%{div}_%{bid}/",
  # "!5200.tv"      => "https://www.5200.tv/%{div}_%{bid}/",
  "!paoshu8.com" => "http://www.paoshu8.com/%{div}_%{bid}/",
  # "!duokan8.com" => "http://www.duokanba.com/%{div}_%{bid}/",
  # "!shubaow.net"  => "https://www.shubaow.net/%{div}_%{bid}/",
  # "!zxcs.me"      => "http://www.zxcs.me/post/%{bid}/",
  # "!biqugee.com"  => "https://www.biqugee.com/book/%{bid}/",
  # "!bxwxorg.com"  => "https://www.bxwxorg.com/read/%{bid}/",
  # "!zhwenpg.com"  => "https://novel.zhwenpg.com/b.php?id=%{bid}",
  # "!nofff.com"    => "https://www.sdyfcm.com/%{bid}/",
  # "!jx.la"        => "https://www.jx.la/book/%{bid}/",
}

bg_seeds = WN::WnSeed.repo.open_db do |db|
  db.query_all "select wn_id, sname, s_bid from seeds where sname like '!%'", as: {Int32, String, Int32}
end

slinks = Hash(Int32, Array(String)).new { |h, k| h[k] = [] of String }

output = bg_seeds.compact_map do |wn_id, sname, s_bid|
  next unless link = MAP[sname]?
  slink = link % {div: s_bid // 1000, bid: s_bid}
  slinks[wn_id] << slink

  {[slink].to_json, sname, s_bid}
end

keys = MAP.keys.map!(&.[1..])

WN::WnSeed.repo.open_tx do |db|
  query = "update seeds set rm_links = ? where sname = ? and s_bid = ?"
  query_2 = "update seeds set rm_links = ? where sname like '@%' and wn_id = ?"

  output.each do |slink, sname, s_bid|
    db.exec query, slink, sname, s_bid
  end

  slinks.each do |wn_id, links|
    links.sort_by! do |slink|
      keys.index { |key| slink.includes?(key) } || 999
    end

    db.exec query, links.first(3).to_json, "_", wn_id
    db.exec query_2, links.first(5).to_json, wn_id
  end
end
