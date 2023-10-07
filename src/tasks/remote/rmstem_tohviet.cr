require "pg"
require "sqlite3"

ENV["CV_ENV"] ||= "production"

require "../../rdapp/data/rmstem"
require "../../mt_ai/core/qt_core"

RM_SQL = "select * from rmstems where btitle_vi = ''"

MCORE = MT::QtCore.hv_name

HVIET = Hash(String, String).new do |h, k|
  h[k] = MCORE.translate(k, true)
end

rstems = PGDB.query_all(RM_SQL, as: RD::Rmstem)

index = 0
rstems.each_slice(100) do |slice|
  puts "- #{index} #{slice.size}"
  index &+= 1

  PGDB.transaction do |tx|
    db = tx.connection

    slice.each do |rstem|
      rstem.btitle_vi = HVIET[rstem.btitle_zh]
      rstem.author_vi = HVIET[rstem.author_zh]

      # TODO: translate description
      rstem.genre_vi = rstem.genre_zh.split('\t').map { |x| HVIET[x] }.join('\t')

      rstem.update!(db: db)
    end
  end
end
