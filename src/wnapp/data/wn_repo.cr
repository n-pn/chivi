require "sqlite3"
require "../../mt_v1/mt_core"
require "./wn_chap"

class WN::WnRepo
  getter db_path : String

  def initialize(@db_path)
    init_db(self.class.init_sql) unless File.file?(db_path)
  end

  def init_db(init_sql : String = self.class.init_sql)
    open_db do |db|
      init_sql.split(";") { |sql| db.exec(sql) unless sql.blank? }
    end
  end

  def open_db
    DB.open("sqlite3:#{@db_path}") { |db| yield db }
  end

  def open_tx
    open_db do |db|
      db.exec "pragma synchronous = normal"
      db.exec "begin"
      yield db
      db.exec "commit"
    end
  end

  def all(pg_no : Int32 = 1, limit = 32) : Array(WnChap)
    open_db do |db|
      offset = (pg_no &- 1) * limit
      query = "select * from chaps where ch_no > ? and ch_no <= ? order by ch_no asc"
      db.query_all query, offset, offset &+ limit, as: WnChap
    end
  end

  def top(take = 6)
    open_db do |db|
      query = "select * from chaps order by ch_no desc limit ?"
      db.query_all query, take, as: WnChap
    end
  end

  def get(ch_no : Int32)
    open_db do |db|
      query = "select * from chaps where ch_no = ? limit 1"
      db.query_one? query, ch_no, as: WnChap
    end
  end

  ###

  private def upsert_sql(fields : Enumerable(String))
    String.build do |sql|
      sql << "insert into chaps ("
      fields.join(sql, ", ")
      sql << ") values ("

      fields.join(sql, ", ") { |_, io| io << '?' }
      sql << ") on conflict (ch_no) do update set "

      fields.join(sql, ", ") { |f, io| io << f << " = excluded." << f }
      sql << " where ch_no = excluded.ch_no"
    end
  end

  def upsert_infos(raw_infos)
    open_tx do |db|
      query = upsert_sql({"ch_no", "s_cid", "title", "chdiv"})

      raw_infos.each do |raw|
        db.exec query, raw.chidx, raw.schid.to_i, raw.title, raw.chvol
      end
    end
  end

  def upsert_entry(entry : WnChap)
    open_tx do |db|
      fields, values = entry.get_changes
      query = upsert_sql(fields)
      db.exec query, args: values
    end
  end

  ###

  def bulk_update(fields : Enumerable(String), values : Array(Enumerable(DB::Any)))
    return 0 if values.empty?

    query = String.build do |sql|
      sql << "update chaps set "
      fields.join(sql, ", ") { |f, io| io << f << " = ?" }
      sql << " where ch_no = ?"
    end

    open_tx do |db|
      values.each { |args| db.exec query, args: args.to_a }
    end

    values.size
  end

  def copy_full(zh_db_path : String)
    open_db do |db|
      db.exec "pragma synchronous = normal"
      db.exec "attach database '#{zh_db_path}' as src"

      db.exec "begin"
      db.exec "insert or replace into chaps select * from src.chaps"
      db.exec "commit"
    end

    self
  end

  def copy_bg_to_fg(bg_db_path : String,
                    bg_sname : String, bg_s_bid : Int32,
                    chmin = 0, chmax = 999, offset = 0)
    open_tx do |db|
      db.exec "attach database '#{bg_db_path}' as src"

      query = <<-SQL
        insert or replace into chaps (
          title, chdiv, c_len, p_len, mtime, uname,
          ch_no, s_cid, _path)
        select
          title, chdiv, c_len, p_len, mtime, uname,
          sc.ch_no + #{offset} as ch_no,
          (sc.ch_no + #{offset}) * 10 as s_cid,
          ? || '/' || ? || '/' || sc.s_cid || ':' || sc.ch_no || ':' || sc.p_len as _path
        from src.chaps as sc where sc.ch_no >= ? and sc.ch_no <= ?
      SQL

      db.exec query, bg_sname, bg_s_bid, chmin, chmax
    end
  end

  ###

  def regen_tl!(zh_db_path : String, dname : String)
    # FIXME: make this more performant by only retranslate what changed
    self.copy_full(zh_db_path) # copy raw data

    trans = [] of {String, String, Int32}
    cvmtl = CV::MtCore.generic_mtl(dname)

    open_db do |db|
      query = "select ch_no, title, chdiv from chaps"

      db.query_each(query) do |rs|
        ch_no, title, chdiv = rs.read(Int32, String, String)

        title = cvmtl.cv_title(title).to_txt unless title.blank?
        chdiv = cvmtl.cv_title(chdiv).to_txt unless chdiv.blank?

        trans << {title, chdiv, ch_no} unless title.empty?
      end
    end

    self.bulk_update({"title", "chdiv"}, trans)

    self
  end

  ####

  CACHE = {} of String => self

  def self.load(db_path : String)
    CACHE[db_path] ||= new(db_path)
  end

  def self.load(sname : String, s_bid : Int32, kind : String)
    db_path = self.db_path(sname, s_bid, kind)
    CACHE[db_path] ||= new(db_path)
  end

  def self.load_tl(zh_db_path : String, dname : String, force : Bool = false)
    vi_db_path = zh_db_path.sub("infos.db", "trans.db")
    repo = new(vi_db_path)

    if force || older?(vi_db_path, zh_db_path)
      repo.regen_tl!(zh_db_path, dname)
    end

    repo
  end

  # return true if the vi_repo is older than the zh_repo or its last mtime > 12 hours
  def self.older?(target : String, source : String, stale : Time::Span = 12.hours)
    return true unless target_mtime = mtime(target)
    return false unless target_mtime = mtime(source)
    target_mtime < {Time.utc - stale, target_mtime}.min
  end

  def self.mtime(path : String)
    File.info?(path).try(&.modification_time)
  end

  ####

  DIR = "var/chaps/infos"

  @[AlwaysInline]
  def self.db_path(sname : String, s_bid : Int32, kind : String = "infos")
    "#{DIR}/#{sname}/#{s_bid}-#{kind}.db"
  end

  @[AlwaysInline]
  def self.db_path(db_name : String)
    "#{DIR}/#{db_name}.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/init_wn_chap.sql") }}
  end
end

# repo = WN::WnRepo.new("tmp/chaps/fg.db")
# repo.copy_bg_to_fg("tmp/chaps/bg.db", "hetushu", 10, chmin: 5, offset: -4)
