require "../../mt_ai/core/qt_core"
require "../../_data/_data"
require "./uprepo"

class UP::Upstem
  class_getter db : DB::Database = PGDB

  ###

  include Crorm::Model
  schema "upstems", :postgres, strict: false

  field id : Int32, pkey: true, auto: true

  field sname : String = "--"
  field mtime : Int64 = Time.utc.to_unix

  field viuser_id : Int32 = 0
  field wninfo_id : Int32? = nil

  field zname : String = ""
  field vname : String = ""

  field vintro : String = ""
  field labels : Array(String) = [] of String

  field gifts : Int16 = 2
  field multp : Int16 = 4
  field guard : Int16 = 0
  field wndic : Bool = false

  field chap_count : Int32 = 0
  field word_count : Int32 = 0

  timestamps

  @[DB::Field(ignore: true, auto: true)]
  @[JSON::Field(ignore: true)]
  getter clist : Chrepo { Chrepo.load(@sname, @id.to_s) }

  def initialize(@viuser_id, @sname, @zname, @vname = "", @labels = [] of String)
    after_initialize
  end

  def mkdirs!
    Dir.mkdir_p("var/stems/up#{@sname}")
    Dir.mkdir_p("var/texts/up#{@sname}/#{@id}")
  end

  def after_initialize
    @vname = MT::QtCore.tl_hvname(@zname) if @vname.empty?

    @labels.map! { |label| MT::QtCore.tl_hvword(label.strip, cap: true) }
    @labels.reject!(&.blank?).uniq!
  end

  def get_chaps(chmin : Int32, limit : Int32 = 32)
    chmax = chmin &+ limit
    chmax = chmax > @chap_count ? @chap_count : chmax
    self.clist.get_all(chmin: chmin, chmax: chmax)
  end

  def top_chaps(limit : Int32 = 4)
    self.clist.get_top(chmax: @chap_count, limit: limit)
  end

  def tl_chap_info!(chmin : Int32 = 0, chmax : Int32 = @chap_count)
    self.clist.update_vinfos!(@wninfo_id || 0, chmin: chmin, chmax: chmax)
  end

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix)
    @chap_count = chmax if @chap_count < chmax
    @mtime = mtime if @mtime < mtime

    query = @@schema.update_stmt(%w{chap_count mtime})
    @@db.exec(query, @chap_count, @mtime, @id)
  end

  @[AlwaysInline]
  def gift_chaps
    return @chap_count if @gifts == 0

    gift_chaps = @chap_count * @gifts // 4
    gift_chaps < 40 ? 40 : gift_chaps
  end

  @[AlwaysInline]
  def chap_plock(ch_no : Int32, vu_id : Int32 = 0)
    return 0 if @viuser_id == vu_id
    ch_no <= gift_chaps ? 0 : 5
  end

  #####

  def self.find(id : Int32, uname : Nil = nil)
    query = @@schema.select_stmt(&.<< "where id = $1 limit 1")
    self.db.query_one?(query, id, as: self)
  end

  def self.find(id : Int32, uname : String)
    query = @@schema.select_stmt do |sql|
      sql << <<-SQL
        where id = $1 and viuser_id = (select id from viusers where uname = $2)
        limit 1
        SQL
    end

    self.db.query_one?(query, id, uname, as: self)
  end

  def self.build_select_sql(guard : Int32 = 4,
                            order = "mtime",
                            uname : String? = nil,
                            label : String? = nil,
                            wn_id : Int32? = nil)
    args = [guard] of String | Int32

    query = String.build do |sql|
      sql << "select * from #{@@schema.table} where guard <= $1"

      if uname
        args << uname
        sql << " and viuser_id = (select id from viusers where uname = $2)"
      end

      if label
        args << label
        sql << " and $#{args.size} = any(labels)"
      end

      if wn_id
        args << wn_id
        sql << " and wninfo_id = $#{args.size}"
      end

      case order
      when "ctime" then sql << " order by id desc"
      when "mtime" then sql << " order by mtime desc"
      when "wsize" then sql << " order by word_count desc"
      end

      sql << " limit $#{args.size &+ 1} offset $#{args.size &+ 2}"
    end

    {query, args}
  end
end
