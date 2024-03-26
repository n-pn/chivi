ENV["CV_ENV"] ||= "production"
require "../../src/rdapp/data/rmstem"

rstems = RD::Rmstem.db.query_all "select * from rmstems where wn_id > 0 order by wn_id", as: RD::Rmstem

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

puts "total: #{rstems.size}"

can_delete = [] of RD::Rmstem
must_keep = [] of RD::Rmstem

rstems.group_by(&.wn_id).each do |wn_id, stems|
  has_best = stems.any? { |x| TYPES[x.sname] == 1 }
  has_live = stems.any? { |x| TYPES[x.sname] == 2 }

  has_dead = stems.select { |x| TYPES[x.sname] == 3 }

  if has_best || has_live
    can_delete.concat(has_dead)
  else
    must_keep.concat(has_dead)
  end
end

puts "can_delete: #{can_delete.size}"
puts "must_keep: #{must_keep.size}"

File.open("/srv/chivi/zroot/can_delete.tsv", "w") do |file|
  can_delete.each do |stem|
    file << stem.sname << '\t' << stem.sn_id << '\t' << stem.chap_count << '\n'
  end
end

File.open("/srv/chivi/zroot/must_keep.tsv", "w") do |file|
  must_keep.each do |stem|
    file << stem.sname << '\t' << stem.sn_id << '\t' << stem.chap_count << '\n'
  end
end
