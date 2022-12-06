require "../src/zhlib/models/zh_chap"

INP = "var/chaps/texts"
OUT = "var/chaps/seeds"

def import(sname : String, s_bid : Int32)
  inp_path = File.join(INP, sname, s_bid.to_s, "index.db")
  return unless File.exists?(inp_path)

  out_path = File.join(OUT, sname, "#{s_bid}.db")

  if info = File.info?(out_path)
    return if info.modification_time > File.info(inp_path).modification_time
  else
    ZH::ZhChap.init_db(sname, s_bid)
  end

  puts "import to: #{out_path}"

  ZH::ZhChap.open_db(sname, s_bid) do |db|
    db.exec %{attach database '#{inp_path}' as inp}
    db.exec <<-SQL
      insert into chaps (ch_no, s_cid, chdiv, title, c_len, p_len, mtime, uname)
      select ch_no, s_cid, chvol, title, c_len, p_len, utime, uname from inp.chinfos
      where true
      on conflict (ch_no) do update set
        s_cid = excluded.s_cid,
        chdiv = excluded.chdiv,
        title = excluded.title,
        c_len = excluded.c_len,
        p_len = excluded.p_len,
        mtime = excluded.mtime,
        uname = excluded.uname
      where excluded.ch_no = chaps.ch_no
    SQL
  end
rescue err
  puts err
end

def import_all(sname : String)
  s_bids = Dir.children("#{INP}/#{sname}").map(&.to_i)
  s_bids.each { |s_bid| import(sname, s_bid) }
end

snames = Dir.children(INP)

snames.each do |sname|
  next if sname.in? "=base", "=user"
  import_all(sname)
end
