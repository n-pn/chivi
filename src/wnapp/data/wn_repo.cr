require "sqlite3"
require "../../mt_v1/core/m1_core"
require "./wn_chap"

class WN::WnRepo
  getter db_path : String

  def initialize(@db_path, wn_id : Int32)
    init_db(self.class.init_sql) unless File.file?(db_path)
    @cvmtl = M1::MtCore.generic_mtl(wn_id)
    self.translate!
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

  def init_db(init_sql : String = self.class.init_sql)
    open_tx do |db|
      init_sql.split(";") { |sql| db.exec(sql) unless sql.blank? }

      zh_db_path = @db_path.sub(".db", "-infos.db")
      next unless File.exists?(zh_db_path)

      db.exec "attach database '#{zh_db_path}' as src"

      db.exec <<-SQL
        replace into chaps (
          ch_no, s_cid,
          title, chdiv,
          c_len, p_len,
          mtime, uname,
          _path, _flag)
        select
          ch_no, s_cid,
          title, chdiv,
          c_len, p_len,
          mtime, uname,
          _path, _flag
        from src.chaps
      SQL
    end
  end

  def translate!(min = 1, max = 99999)
    open_tx do |db|
      query = <<-SQL
        select title, chdiv, ch_no from chaps
        where ch_no >= ? and ch_no <= ?
      SQL

      raws = db.query_all(query, min, max, as: {String, String, Int32})

      raws.each do |ztitle, zchdiv, ch_no|
        upsert_trans(db, ztitle, zchdiv, ch_no)
      end
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
      query = "select * from chaps where ch_no > 0 order by ch_no desc limit ?"
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

  def delete_chaps!(from_ch_no : Int32)
    open_tx do |db|
      # delete previous deleted entries
      db.exec "delete from chaps where ch_no <= ?", -from_ch_no

      # soft delete entries by reverting `ch_no` value
      db.exec "update chaps set ch_no = -ch_no where ch_no >= ?", from_ch_no
    end
  end

  ###

  private def upsert_sql(fields : Enumerable(String), unsafe : Bool = false)
    String.build do |sql|
      sql << "insert into chaps ("
      fields.join(sql, ", ")
      sql << ") values ("

      fields.join(sql, ", ") { |_, io| io << '?' }
      sql << ") on conflict (ch_no) do update set "

      fields.join(sql, ", ") { |f, io| io << f << " = excluded." << f }
      sql << " where ch_no = excluded.ch_no"
      # sql << " and _flag < 2" unless unsafe
    end
  end

  def upsert_chap_infos(chapters : Enumerable(WnChap))
    open_tx do |db|
      query = upsert_sql(WnChap::INFO_FIELDS, unsafe: true)

      chapters.each do |chap|
        db.exec query, *chap.info_values
        upsert_trans(db, chap.title, chap.chdiv, chap.ch_no)
      end
    end
  end

  def upsert_chap_full(chap : WnChap)
    open_tx do |db|
      query = upsert_sql(WnChap::FULL_FIELDS, unsafe: false)
      db.exec query, *chap.full_values
      upsert_trans(db, chap.title, chap.chdiv, chap.ch_no)
    end
  end

  private def upsert_trans(db, ztitle : String, zchdiv : String, ch_no : Int32)
    return if ztitle.empty?

    vtitle = @cvmtl.cv_title(ztitle).to_txt
    vchdiv = zchdiv.blank? ? "" : @cvmtl.cv_title(zchdiv).to_txt

    query = "update chaps set vtitle = ?, vchdiv = ? where ch_no = ?"
    db.exec query, vtitle, vchdiv, ch_no
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

  # def copy_bg_to_fg(bg_db_path : String,
  #                   bg_sname : String, bg_s_bid : Int32,
  #                   chmin = 0, chmax = 999, offset = 0)
  #   open_tx do |db|
  #     db.exec "attach database '#{bg_db_path}' as src"

  #     query = <<-SQL
  #       insert or replace into chaps (
  #         title, chdiv, c_len, p_len, mtime, uname,
  #         ch_no, s_cid, _path)
  #       select
  #         title, chdiv, c_len, p_len, mtime, uname,
  #         sc.ch_no + #{offset} as ch_no,
  #         (sc.ch_no + #{offset}) * 10 as s_cid,
  #         ? || '/' || ? || '/' || sc.s_cid || ':' || sc.ch_no || ':' || sc.p_len as _path
  #       from src.chaps as sc where sc.ch_no >= ? and sc.ch_no <= ?
  #     SQL

  #     db.exec query, bg_sname, bg_s_bid, chmin, chmax
  #   end
  # end

  ####

  CACHE = {} of String => self

  @[AlwaysInline]
  def self.load(db_path : String, wn_id : Int32)
    CACHE[db_path] ||= new(db_path, wn_id)
  end

  @[AlwaysInline]
  def self.load(sname : String, s_bid : Int32, wn_id : Int32)
    db_path = self.db_path(sname, s_bid)
    self.load(db_path, wn_id)
  end

  ###

  DIR = "var/chaps/infos"

  @[AlwaysInline]
  def self.db_path(sname : String, s_bid : Int32)
    "#{DIR}/#{sname}/#{s_bid}.db"
  end

  @[AlwaysInline]
  def self.db_path(db_name : String)
    "#{DIR}/#{db_name}.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/init_wn_chap.sql") }}
  end

  ####

  def self.soft_delete!(sname : String, s_bid : Int32) : Nil
    db_path = self.db_path(sname, s_bid)

    # checking if file exists to make sure, though this file should be alwasy available
    return unless File.file?(db_path)

    # instead of remove data, just change `s_bid` value so it can't be reached.
    dead_path = db_path(sname, -s_bid)

    # delete old deleted database file if existed
    File.delete?(dead_path)

    File.rename(db_path, dead_path)
    CACHE.delete(db_path)
  end
end
