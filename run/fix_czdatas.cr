require "../src/rdapp/data/czdata"

INP = ARGV[0]? || "/www/restore/czdata"
OUT = ARGV[1]? || "/srv/chivi/wn_db"

UPSERT_ZTEXT_SQL = <<-SQL
insert into czdata(ch_no, title, ztext, zsize, cksum, mtime)
values ($1, $2, $3, $4, $5, $6)
on conflict(ch_no) do update set
  title = excluded.title,
  ztext = excluded.ztext,
  zsize = excluded.zsize,
  cksum = excluded.cksum,
  mtime = excluded.mtime
where $6 >= czdata.mtime
SQL

Dir.children(INP).each do |sname|
  inp_paths = Dir.glob("#{INP}/#{sname}/*-zdata.db3")

  inp_paths.each do |inp_path|
    zdatas = [] of RD::Czdata

    DB.open("sqlite3:#{inp_path}") do |db|
      db.query_each "select ch_no, title, ztext, mtime from czdata where ztext <> ''" do |rs|
        ch_no, title, ztext, mtime = rs.read(Int32, String, String, Int64)
        ztext = "#{title}\n#{ztext}" unless ztext.starts_with?(title)

        zdatas << RD::Czdata.new(
          ch_no: ch_no,
          title: CharUtil.fast_sanitize(title),
          ztext: CharUtil.fast_sanitize(ztext),
          mtime: mtime
        )
      end
    end

    next if zdatas.empty?

    RD::Czdata.db(inp_path.sub(INP, OUT)).open_tx do |db|
      zdatas.each do |zdata|
        db.exec UPSERT_ZTEXT_SQL, zdata.ch_no, zdata.title, zdata.ztext, zdata.zsize, zdata.cksum, zdata.mtime
      end
    end

    puts "#{inp_path} updated, #{zdatas.size} entries saved!"
  rescue ex
    puts ex
  end
end
