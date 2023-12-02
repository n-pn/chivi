ENV["CV_ENV"] ||= "production"
require "../../src/rdapp/data/*"

def regen_wnstems
  wnstems = RD::Wnstem.all_by_sname("~avail")
  puts "wn: #{wnstems.size}"

  tsrepos = wnstems.map do |wstem|
    repo = RD::Tsrepo.new("wn~avail/#{wstem.wn_id}")
    repo.owner = -1
    repo.stype = 0_i16
    repo.sname = "wn~avail"

    repo.sn_id = wstem.wn_id
    repo.wn_id = wstem.wn_id

    repo.chmax = wstem.chap_total

    repo.plock = 1
    repo.multp = wstem.multp

    repo.mtime = wstem.mtime

    repo
  end

  tsrepos.each_slice(10000) do |slice|
    PGDB.transaction do |tx|
      db = tx.connection
      slice.each(&.upsert!(db: db))
      puts "saved: #{slice.size}"
    end
  end
end

def regen_upstems
  upstems = RD::Upstem.get_all
  puts "up: #{upstems.size}"

  tsrepos = upstems.map do |ustem|
    repo = RD::Tsrepo.new("up#{ustem.sname}/#{ustem.id!}")
    repo.owner = ustem.owner

    repo.stype = 1_i16
    repo.sname = ustem.sname

    repo.sn_id = ustem.id!
    repo.wn_id = ustem.wn_id || 0

    repo.zname = ustem.zname
    repo.vname = ustem.vname

    repo.chmax = ustem.chap_count

    repo.plock = 1
    repo.multp = ustem.multp

    repo.mtime = ustem.mtime
    repo.view_count = ustem.view_count

    repo
  end

  PGDB.transaction do |tx|
    db = tx.connection
    tsrepos.each(&.upsert!(db: db))
    puts "saved: #{tsrepos.size}"
  end
end

def regen_rmstems
  rmstems = RD::Rmstem.get_all
  existed = PGDB.query_all("select * from tsrepos where stype = 2", as: RD::Tsrepo)

  existed = existed.to_h { |x| {"#{x.sname}/#{x.sn_id}", x} }

  puts "rm: #{rmstems.size}"

  tsrepos = rmstems.map do |rstem|
    repo = existed["#{rstem.sname}/#{rstem.sn_id}"]? || RD::Tsrepo.new("rm#{rstem.sname}/#{rstem.sn_id}")

    repo.owner = -1

    repo.sname = rstem.sname
    repo.stype = 2_i16

    repo.sn_id = rstem.sn_id.to_i
    repo.wn_id = rstem.wn_id || 0
    repo.pdict = rstem.wn_id > 0 ? "wn#{rstem.wn_id}" : "combine"

    repo.zname = rstem.btitle_zh
    repo.vname = rstem.btitle_vi
    repo.cover = rstem.cover_rm

    repo.chmax = rstem.chap_count

    repo.plock = 2
    repo.multp = rstem.multp

    repo.mtime = rstem.update_int

    repo.rm_slink = rstem.rlink
    repo.rm_stime = rstem.stime

    repo.view_count = rstem.view_count
    # repo.like_count = rstem.like_count

    repo
  end

  tsrepos.each_slice(10000) do |slice|
    PGDB.transaction do |tx|
      db = tx.connection
      slice.each(&.upsert!(db: db))
      puts "saved: #{slice.size}"
    end
  end
end

regen_upstems()
# regen_wnstems()
# regen_rmstems()
