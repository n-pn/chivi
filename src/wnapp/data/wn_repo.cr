require "http/client"

require "sqlite3"
require "./wn_chap"

class WN::WnRepo
  getter db_path : String

  def initialize(@db_path, wn_id : Int32)
    @tl_api = "http://127.0.0.1:5110/_m1/qtran/tl_mulu?wn_id=#{wn_id}"
    return if File.file?(db_path)

    init_db(self.class.init_sql)
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
    rescue ex
      db.close
      raise ex
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

  SELECT_RAW_SQL = <<-SQL
    select title, chdiv, ch_no from chaps
    where ch_no >= ? and ch_no <= ?
  SQL

  def translate!(min = 1, max = 99999)
    open_tx do |db|
      ch_nos = [] of Int32
      buffer = String::Builder.new

      db.query_each(SELECT_RAW_SQL, min, max) do |rs|
        buffer << rs.read(String) << '\n' # read title
        buffer << rs.read(String) << '\n' # read chdiv
        ch_nos << rs.read(Int32)          # read ch_no
      end

      translated = tl_mulu(buffer.to_s).lines

      ch_nos.each_with_index do |ch_no, idx|
        break unless vtitle = translated[idx * 2]?
        break unless vchdiv = translated[idx * 2 + 1]?

        update_vnames!(db, vtitle, vchdiv, ch_no)
      end
    rescue ex
      Log.info { @db_path.colorize.red }
      Log.error(exception: ex) { ex.message.colorize.red }
    end
  end

  private def tl_mulu(body : String) : String
    HTTP::Client.post(@tl_api, body: body, &.body_io.gets_to_end) rescue ""
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
    sql = upsert_sql(WnChap::INFO_FIELDS, unsafe: true)

    open_tx do |db|
      buffer = String::Builder.new

      chapters.each do |chap|
        db.exec sql, *chap.info_values
        buffer << chap.title << '\n' << chap.chdiv << '\n'
      end

      translated = tl_mulu(buffer.to_s).lines

      chapters.each_with_index do |chap, idx|
        break unless vtitle = translated[idx * 2]?
        break unless vchdiv = translated[idx * 2 + 1]?

        update_vnames!(db, vtitle, vchdiv, chap.ch_no)
      end
    end
  end

  def upsert_chap_full(chap : WnChap)
    sql = upsert_sql(WnChap::FULL_FIELDS, unsafe: false)

    open_tx do |db|
      db.exec sql, *chap.full_values
      translated = tl_mulu("#{chap.title}\n#{chap.chdiv}").lines
      break if translated.size < 2
      update_vnames!(db, translated[0], translated[1], chap.ch_no)
    end
  end

  UPDATE_VI_SQL = "update chaps set vtitle = ?, vchdiv = ? where ch_no = ?"

  private def update_vnames!(db, vtitle : String, vchdiv : String, ch_no : Int32)
    db.exec(UPDATE_VI_SQL, vtitle, vchdiv, ch_no)
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
    CACHE[db_path] ||= new(db_path, wn_id: wn_id)
  end

  @[AlwaysInline]
  def self.load(sname : String, s_bid : Int32, wn_id : Int32)
    db_path = self.db_path(sname, s_bid)
    self.load(db_path, wn_id: wn_id)
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
