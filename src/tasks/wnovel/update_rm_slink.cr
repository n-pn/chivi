ENV["CV_ENV"] ||= "production"
require "../../rdapp/data/tsrepo"

require "../../rdapp/_raw/rmhost"
require "../../rdapp/data/util/rmrank"

rstems = PGDB.query_all "select * from tsrepos where stype = 2 and wn_id > 0 and sname <> '!zxcs.me", as: RD::Tsrepo
rstems.reject! { |x| TYPES[x.sname] > 2 }

puts "rstems: #{rstems.size}"

TYPES = {
  "!69shuba.com"  => 2,
  "!biqu5200.net" => 2,
  "!biqugee.com"  => 3,
  "!biquluo.cc"   => 2,
  "!bxwx.net"     => 2,
  "!bxwxorg.com"  => 3,
  "!duokanba.com" => 3,
  "!egyguard.com" => 2,
  "!hetushu.com"  => 1,
  "!jx.la"        => 3,
  "!madcowww.com" => 2,
  "!nofff.com"    => 3,
  "!paoshu8.com"  => 3,
  "!piaotia.com"  => 2,
  "!rengshu.com"  => 3,
  "!shubaow.net"  => 3,
  "!tasim.net"    => 2,
  "!uukanshu.com" => 2,
  "!xbiquge.bz"   => 3,
  "!zsdade.com"   => 2,
  "!zxcs.me"      => 1,
}

PGDB.transaction do |tx|
  rstems.group_by(&.wn_id).each do |wn_id, stems|
    stems.sort_by! { |x| {RD::Rmrank.index(x.sname), -x.chmax, -x._flag} }

    next unless first = stems.first?

    rm_slink = Rmhost.stem_url(first.sname, first.sn_id)
    puts "#{wn_id} => #{rm_slink} (#{first.sname})"

    tx.connection.exec "update tsrepos set rm_slink = $1 where stype = 0 and sn_id = $2", rm_slink, wn_id
  end
end

PGDB.transaction do |tx|
  rstems.select(&.rm_slink.empty?).each do |rstem|
    rm_slink = Rmhost.stem_url(rstem.sname, rstem.sn_id)
    tx.connection.exec "update tsrepos set rm_slink = $1 where sname = $2 and sn_id = $3", rm_slink, rstem.sname, rstem.sn_id
  end
end
