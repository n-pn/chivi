require "./_shared"

DIC = DB.open("sqlite3:#{MT::MtDefn.db_path("common-main")}")
at_exit { DIC.close }

struct Defn
  include JSON::Serializable

  getter d_id = 0
  getter _ver = 1

  getter zstr : String
  getter vstr : String

  getter upos : String
  getter _wsr : Int32

  getter mtime : Int32
  getter uname : String

  getter _flag = 3

  def initialize(zstr : String, vstr : String, @upos, @_wsr, @mtime, @uname)
    @zstr = normalize(zstr)
    @vstr = vstr.split(/[ǀ|\t]/).first.gsub(/\p{Cc}/, "").strip
    @_flag = mtime > 0 ? 4 : 3
    @uname = "!cv" if uname.empty?
  end

  UPDATE_STMT = <<-SQL
    insert into defns (d_id, zstr, vstr, _ver, upos, _wsr, mtime, uname, _flag)
    values ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    on conflict(d_id, zstr) do update set
      vstr = excluded.vstr,
      upos = excluded.upos,
      _wsr = excluded._wsr,
      mtime = excluded.mtime,
      uname = excluded.uname
  SQL

  def save!(db : DB::Database)
    db.exec UPDATE_STMT, @d_id, @zstr, @vstr, @_ver, @upos, @_wsr, @mtime, @uname, @_flag
  end
end

defns = {} of String => Defn

DB.open("sqlite3:var/mtdic/users/v1_defns.dic") do |db|
  stmt = <<-SQL
    select
      "key" as zstr,
      "val" as vstr,
      "ptag" as upos,
      "prio" as _wsr,
      "uname",
      "mtime"
    from defns
    where dic = -1 and tab = 1
    order by mtime desc
  SQL

  db.query_each(stmt) do |rs|
    defn = Defn.new(
      zstr: rs.read(String),
      vstr: rs.read(String),
      upos: rs.read(String),
      _wsr: rs.read(Int32),
      uname: rs.read(String),
      mtime: rs.read(Int32),
    )

    defns[defn.zstr] ||= defn
  end
end

puts "defn data: #{defns.size}"

DIC.exec "begin"

defns.each_value(&.save!(DIC))

DIC.exec "commit"
