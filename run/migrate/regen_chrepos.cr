ENV["CV_ENV"] ||= "production"
require "../../src/rdapp/data/*"

def regen_wnstems
  wnstems = RD::Wnstem.all_by_sname("~avail")
  puts "wn: #{wnstems.size}"

  chrepos = wnstems.map do |wstem|
    crepo = RD::Chrepo.new("wn~avail/#{wstem.wn_id}")
    crepo.owner = -1
    crepo.stype = 0_i16
    crepo.sname = "wn~avail"

    crepo.sn_id = wstem.wn_id
    crepo.wn_id = wstem.wn_id

    crepo.chmax = wstem.chap_total

    crepo.plock = 1
    crepo.gifts = 1_i16
    crepo.multp = wstem.multp

    crepo.mtime = wstem.mtime

    crepo
  end

  chrepos.each_slice(10000) do |slice|
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

  chrepos = upstems.map do |ustem|
    crepo = RD::Chrepo.new("up#{ustem.sname}/#{ustem.id!}")
    crepo.owner = ustem.owner

    crepo.stype = 1_i16
    crepo.sname = ustem.sname

    crepo.sn_id = ustem.id!
    crepo.wn_id = ustem.wn_id || 0

    crepo.zname = ustem.zname
    crepo.vname = ustem.vname

    crepo.chmax = ustem.chap_count

    crepo.plock = 1
    crepo.gifts = 1_i16
    crepo.multp = ustem.multp

    crepo.mtime = ustem.mtime
    crepo.view_count = ustem.view_count

    crepo
  end

  PGDB.transaction do |tx|
    db = tx.connection
    chrepos.each(&.upsert!(db: db))
    puts "saved: #{chrepos.size}"
  end
end

def regen_rmstems
  rmstems = RD::Rmstem.get_all
  puts "rm: #{rmstems.size}"

  chrepos = rmstems.map do |rstem|
    crepo = RD::Chrepo.new("rm#{rstem.sname}/#{rstem.sn_id}")
    crepo.owner = -1

    crepo.sname = rstem.sname
    crepo.stype = 2_i16

    crepo.sn_id = rstem.sn_id.to_i
    crepo.wn_id = rstem.wn_id || 0

    crepo.zname = rstem.btitle_zh
    crepo.vname = rstem.btitle_vi

    crepo.chmax = rstem.chap_count
    crepo.avail = rstem.chap_avail

    crepo.plock = 2
    crepo.gifts = 1_i16
    crepo.multp = rstem.multp

    crepo.mtime = rstem.update_int
    crepo.rtime = rstem.stime

    crepo.view_count = rstem.view_count

    crepo
  end

  chrepos.each_slice(10000) do |slice|
    PGDB.transaction do |tx|
      db = tx.connection
      slice.each(&.upsert!(db: db))
      puts "saved: #{slice.size}"
    end
  end
end

regen_upstems()
regen_wnstems()
regen_rmstems()
