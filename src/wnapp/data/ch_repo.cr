require "sqlite3"
require "./ch_info"

class WN::ChRepo
  getter db_path : String

  def initialize(@db_path)
    return if File.file?(db_path)

    # unzip file if the compressed version exists
    if File.file?("#{db_path}.zst")
      `zstd -d '#{db_path}.zst'`
      return if $?.success?
    end

    init_db(self.class.init_sql)
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
    DB.open("sqlite3:#{@db_path}") do |db|
      db.exec "pragma synchronous = normal"
      db.exec "begin"
      yield db
      db.exec "commit"
    end
  end

  def all(pg_no : Int32 = 1, limit = 32) : Array(ChInfo)
    open_db do |db|
      offset = (pg_no &- 1) * limit
      query = "select * from chaps where ch_no >= ? and ch_no < ? order by ch_no asc"
      db.query_all query, offset, offset &+ limit, as: ChInfo
    end
  end

  def top(take = 6)
    open_db do |db|
      query = "select * from chaps order by ch_no desc limit ?"
      db.query_all query, take, as: ChInfo
    end
  end

  def get(ch_no : Int32)
    open_db do |db|
      query = "select * from chaps where ch_no = ? limit 1"
      db.query_one? query, ch_no, as: ChInfo
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

  def upsert_entry(chinfo : ChInfo)
    open_tx do |db|
      fields, values = chinfo.get_changes
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

  def copy_full(src_db_path : String)
    open_db do |db|
      db.exec "pragma synchronous = normal"
      db.exec "attach database '#{src_db_path}' as src"

      db.exec "begin"
      db.exec "insert or replace into chaps select * from src.chaps"
      db.exec "commit"
    end

    self
  end

  def save_info!(info : ChInfo)
    repo.insert(@@table, fields, values, :replace)
  end

  ###

  def regen_tl!(src_db_path : String, dname : String)
    # FIXME: make this more performant by only retranslate what changed
    self.copy_full(src_db_path) # copy raw data

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

  def self.load(sname, s_bid, type, name)
    db_path = self.db_path(sname, s_bid, type, name)
    CACHE[db_path] ||= new(db_path)
  end

  def self.load_tl(zh_db_path : String, dname : String)
    vi_db_path = zh_db_path.sub("infos.db", "trans.db")
    outdated = newer?(zh_db_path, vi_db_path)
    new(vi_db_path).tap { |x| x.regen_tl!(zh_db_path, dname) if outdated }
  end

  ####

  DIR = "var/chaps/infos"

  @[AlwaysInline]
  def self.db_path(sname : String, s_bid : Int32, type : String, name : String)
    "#{DIR}-#{type}/#{sname}/#{s_bid}-#{name}.db"
  end

  @[AlwaysInline]
  def self.db_path(db_name : String)
    "#{DIR}-#{db_name}.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/init_ch_info.sql") }}
  end

  def self.newer?(target : String, source : String)
    return false unless target_info = File.info?(target)
    return true unless source_info = File.info?(source)

    target_info.modification_time > source_info.modification_time
  end
end
