require "../src/zhlib/*"
require "../src/appcv/ch_repo"

def export_names(sname, s_bid, chaps : Array(CV::Chinfo))
  db_path = ZH::ChName::DB_PATH % {sname: sname, s_bid: s_bid}
  ZH::ChName.init_db(db_path) unless File.exists?(db_path)

  names = chaps.map do |chap|
    ZH::ChName.new({
      ch_no: chap.ch_no.not_nil!,
      s_cid: chap.s_cid,
      chvol: chap.chvol,
      title: chap.title,
    })
  end

  repo = Crorm::Adapter.new("sqlite3://./#{db_path}")
  repo.transaction do |db|
    names.each do |name|
      fields, values = name.get_changes

      repo.upsert(db, "names", fields, values, "(ch_no)", nil) do
        keep_fields = fields.reject(&.== "ch_no")
        repo.upsert_stmt(keep_fields) { |field| "excluded.#{field}" }
      end
    end
  end
end

def export_stats(sname, s_bid, chaps : Array(CV::Chinfo))
  db_path = ZH::ChStat::DB_PATH % {sname: sname, s_bid: s_bid}
  ZH::ChStat.init_db(db_path) unless File.exists?(db_path)

  stats = chaps.map do |chap|
    ZH::ChStat.new({
      ch_no: chap.ch_no.not_nil!,
      s_cid: chap.s_cid,

      c_len: chap.c_len,
      p_len: chap.p_len,

      mtime: chap.utime,
      uname: chap.uname,
    })
  end

  repo = Crorm::Adapter.new("sqlite3://./#{db_path}")
  repo.transaction do |db|
    stats.each do |name|
      fields, values = name.get_changes

      repo.upsert(db, "stats", fields, values, "(ch_no)", nil) do
        keep_fields = fields.reject(&.== "ch_no")
        repo.upsert_stmt(keep_fields) { |field| "excluded.#{field}" }
      end
    end
  end
end

DIR = "var/chaps/texts/%{sname}"

def migrate_source(sname : String)
  dir = DIR % {sname: sname}
  s_bids = Dir.children(dir).map(&.to_i).sort!

  Dir.mkdir_p("var/chaps/infos/#{sname}")
  track_file = "var/chaps/infos/#{sname}-mapped.tsv"

  buffer = [] of Tuple(Int32, Int32)

  s_bids.each_with_index(1) do |s_bid, idx|
    chaps = CV::ChRepo.new(sname, s_bid).all(0, 99999)
    puts "- <#{idx}> #{s_bid}: #{chaps.size} chapters"
    buffer << {s_bid, chaps.size}

    unless File.exists?(ZH::ChStat::DB_PATH % {sname: sname, s_bid: s_bid})
      export_names(sname, s_bid, chaps)
      export_stats(sname, s_bid, chaps)
    end

    if idx % 128 == 0
      File.open(track_file, "a") do |io|
        buffer.each { |a, b| io << a << '\t' << b << '\n' }
      end
      buffer.clear
    end
  rescue err
    puts err
  end
end

ARGV.each do |sname|
  migrate_source(sname)
end
