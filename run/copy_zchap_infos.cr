require "sqlite3"

INP = "var/chaps/infos"
OUT = "/2tb/var.chivi/zchap/globs"

def init_db(db_path : String)
  DB.open("sqlite3:#{db_path}") do |db|
    db.exec "pragma journal_mode=WAL"
    db.exec <<-SQL
    create table chaps(
      ch_no int primary key,
      s_cid varchar not null,
      ctitle varchar not null default '',
      subdiv varchar not null default '',
      wcount int not null default 0,
      mtime bigint not null default 0
    )
    SQL
  end
end

def import_db(out_path : String, inp_path)
  DB.open("sqlite3:#{out_path}") do |db|
    db.exec "attach database '#{inp_path}' as inp"
    db.exec <<-SQL
      replace into chaps (ch_no, s_cid, ctitle, subdiv, wcount, mtime)
      select ch_no, s_cid as varchar, title, chdiv, c_len, mtime
      from inp.chaps
      SQL
  end

  puts "- #{inp_path} => #{out_path}"
end

def import_all(inp_sname : String, out_sname : String)
  out_dir = "#{OUT}/#{out_sname}"
  Dir.mkdir_p(out_dir)

  files = Dir.glob("#{INP}/#{inp_sname}/*.db")
  files.each do |inp_path|
    s_bid = File.basename(inp_path, ".db")
    next if s_bid.starts_with?('-') || s_bid.ends_with?('s')

    out_path = "#{out_dir}/#{s_bid}.db3"

    init_db(out_path) unless File.exists?(out_path)
    import_db(out_path, inp_path)
  rescue err
    puts err, inp_path
  end
end

mapping = {
  {"!zxcs.me", "!zxcs_me"},
  {"!yannuozw.com", "!yannuozw"},
  {"!xbiquge.so", "!xbiquge"},
  {"!uuks.org", "!uuks_org"},
  {"!uukanshu.com", "!uukanshu"},
  {"!shubaow.net", "!shubaow"},
  {"!rengshu.com", "!rengshu"},
  {"!hetushu.com", "!hetushu"},
  {"!ptwxz.com", "!ptwxz"},
  {"!paoshu8.com", "!paoshu8"},
  {"!nofff.com", "!nofff"},
  {"!kanshu8.net", "!kanshu8"},
  {"!jx.la", "!jx_la"},
  {"!duokan8.com", "!duokan8"},
  {"!chivi.app", "!chivi"},
  {"!bxwxorg.com", "!bxwxorg"},
  {"!bxwx.io", "!bxwx_io"},
  {"!bqxs520.com", "!bqxs520"},
  {"!biqugse.com", "!biqugse"},
  {"!biqugee.com", "!biqugee"},
  {"!biqu5200.net", "!biqu5200"},
  {"!b5200.org", "!b5200_org"},
  {"!5200.tv", "!5200_tv"},
  {"!133txt.com", "!133txt"},
  {"!69shu.com", "!69shu"},
}

mapping.each do |inp_name, out_name|
  import_all(inp_name, out_name)
end

# Dir.children(INP).each do |sname|
#   import_all(sname) unless sname.starts_with?('!')
# end
