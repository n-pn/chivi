require "./_shared"

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

  def initialize(rs : ::DB::ResultSet)
    @d_id = rs.read(Int32)
    @d_id = 0 if @d_id < 0

    @zstr = normalize(rs.read(String))
    @vstr = rs.read(String).split(/[ǀ|\t]/).first.gsub(/\p{Cc}/, "").strip

    @upos = rs.read(String)
    @_wsr = rs.read(Int32)

    @uname = rs.read(String)
    @mtime = rs.read(Int32)

    @uname = "!cv" if @uname.empty?
    @_flag = @mtime > 0 ? 4 : 3
  end

  UPDATE_STMT = <<-SQL
    insert into defns (d_id, zstr, vstr, _ver, upos, _wsr, mtime, uname, _flag)
    values ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    on conflict(d_id, zstr) do update set
      vstr = excluded.vstr, upos = excluded.upos, _wsr = excluded._wsr,
      mtime = excluded.mtime, uname = excluded.uname
      where _flag < 4
    SQL

  def save!(db : DB::Database)
    db.exec UPDATE_STMT, @d_id, @zstr, @vstr, @_ver, @upos, @_wsr, @mtime, @uname, @_flag
  end
end

def transfer(db_path : String, where_dic : String)
  defns = {} of String => Defn

  DB.open("sqlite3:var/mtdic/users/v1_defns.dic") do |db|
    stmt = <<-SQL
      select dic as d_id, "key" as zstr, "val" as vstr, "ptag" as upos, "prio" as _wsr, "uname", "mtime"
      from defns where #{where_dic} order by mtime desc
      SQL

    db.query_each(stmt) do |rs|
      defn = Defn.new(rs)
      defns[defn.zstr] ||= defn
    end
  end

  puts "#{db_path}: #{defns.size} items"

  DB.open("sqlite3:#{db_path}?synchronous=norma") do |db|
    db.exec "begin"
    defns.values.sort_by!(&.mtime).each(&.save!(db))
    db.exec "commit"
  end
end

transfer(MT::MtDefn.db_path("common-main"), "dic = -1 and tab = 1")
transfer(MT::MtDefn.db_path("wnovel-main"), "dic > 0 and tab = 1")
transfer(MT::MtDefn.db_path("common-user"), "dic = -1 and tab > 1")
transfer(MT::MtDefn.db_path("wnovel-user"), "dic > 0 and tab > 1")
