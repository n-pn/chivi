require "../src/zroot/rmbook"

INP = "/2tb/var.chivi/zbook"
OUT = "/2tb/var.chivi/zroot/remote"

Dir.glob("#{INP}/*.db").each do |inp_path|
  sname = "!" + File.basename(inp_path, ".db")
  puts "#{inp_path} => #{ZR::Rmbook.db_path(sname)}"

  ZR::Rmbook.db_open(sname) do |db|
    db.exec "attach 'file:#{inp_path}' as inp"

    db.exec <<-SQL
      replace into rmbooks (
        id, btitle, author,
        cover, intro, genre, xtags,
        status_str, update_str, latest_cid,
        chap_count, chap_avail,
        rtime, _flag
        )
      select
        cast(id as text), btitle, author,
        cover, intro, genre, "" as xtags,
        pub_status as status_str, updated_at as update_str, latest_cid,
        chap_count, chap_avail,
        _utime as rtime, _grade as _flag
        from inp.books
    SQL
  end
end
