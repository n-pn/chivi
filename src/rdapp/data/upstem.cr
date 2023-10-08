require "../../mt_ai/core/qt_core"
require "../../_data/_data"

require "./chrepo"

class RD::Upstem
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
  getter crepo : Chrepo do
    Chrepo.load("up#{@sname}/#{@id}").tap do |repo|
      repo.zname = @zname
      repo.chmax = @chap_count
      repo.wn_id = @wninfo_id || 0
      repo.gifts = @gifts
      repo.plock = 5

      # repo.update_vinfos!
    end
  end

  def initialize(@viuser_id, @sname, @zname, @vname = "", @labels = [] of String)
    after_initialize
  end

  def after_initialize
    @vname = MT::QtCore.tl_hvname(@zname) if @vname.empty?
    @labels.map! { |label| MT::QtCore.tl_hvword(label.strip, cap: true) }
    @labels.reject!(&.blank?).uniq!
  end

  def tl_chap_info!(start : Int32 = 1, limit : Int32 = @chap_count)
    self.crepo.update_vinfos!(start: start, limit: limit)
  end

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix)
    @mtime = mtime if @mtime < mtime

    @chap_count = chmax if @chap_count < chmax
    self.crepo.chmax = @chap_count

    query = @@schema.update_stmt(%w{chap_count mtime})
    @@db.exec(query, @chap_count, @mtime, @id)
  end

  #####

  def self.find(id : Int32, sname : Nil = nil)
    query = @@schema.select_stmt(&.<< "where id = $1 limit 1")
    self.db.query_one?(query, id, as: self)
  end

  def self.find(id : Int32, sname : String)
    query = @@schema.select_stmt(&.<< "where id = $1 and sname = $2 limit 1")
    self.db.query_one?(query, id, sname, as: self)
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
