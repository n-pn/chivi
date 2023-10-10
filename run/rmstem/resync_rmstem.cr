# sync rmstem with old wnstem entries

require "pg"
require "sqlite3"

ENV["CV_ENV"] ||= "production"

require "../../src/rdapp/data/rmstem"
require "../../src/rdapp/data/wnstem"

RM_SQL = "select * from rmstems where sname = $1 and _flag <> -404 order by sn_id asc"
WN_SQL = "select * from wnseeds where sname = $1"

def resync(sname : String)
  rstems = PGDB.query_all(RM_SQL, sname, as: RD::Rmstem).to_h do |rstem|
    {rstem.sn_id, rstem}
  end

  wstems = PGDB.query_all WN_SQL, sname, as: RD::Wnstem

  index = 0
  wstems.each_slice(100) do |slice|
    puts "- #{index} [#{sname}]: #{slice.size}"
    index &+= 1

    PGDB.transaction do |tx|
      db = tx.connection

      slice.each do |wstem|
        next unless rstem = rstems[wstem.s_bid]?
        rstem.wn_id = wstem.wn_id

        if rstem.chap_count < wstem.chap_total
          rstem.chap_count = wstem.chap_total
          rstem.chap_avail = wstem.chap_avail
          rstem.update_int = wstem.mtime
          rstem.stime = wstem.rtime
        end

        rstem.update!(db: db)
      end
    end
  end
end

# resync("!biqugee.com")
# resync("!bxwxorg.com")
# resync("!xbiquge.bz")
# resync("!jx.la")
resync("!zxcs.me")
