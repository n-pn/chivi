require "../../mt_ai/core/qt_core"
require "../../_data/_data"

require "./chrepo"

class RD::Upstem
  class_getter db : DB::Database = PGDB

  ###

  include Crorm::Model
  schema "upstems", :postgres, strict: false

  field id : Int32, pkey: true, auto: true

  field sname : String
  field owner : Int32

  field zname : String
  field vname : String = ""

  field vintro : String = ""
  field labels : Array(String) = [] of String

  field gifts : Int16 = 2
  field multp : Int16 = 4
  field guard : Int16 = 0

  field wn_id : Int32? = nil
  field wndic : Bool = false

  field mtime : Int64 = Time.utc.to_unix

  field chap_count : Int32 = 0
  field view_count : Int32 = 0

  timestamps

  @[DB::Field(ignore: true, auto: true)]
  @[JSON::Field(ignore: true)]
  getter crepo : Chrepo do
    Chrepo.load("up#{@sname}/#{@id}").tap do |repo|
      repo.zname = @zname
      repo.chmax = @chap_count
      repo.wn_id = @wn_id || 0
      repo.gifts = @gifts
      repo.plock = 5

      repo.update_vinfos!
    end
  end

  def initialize(@owner, @sname, @zname, @vname = "", @labels = [] of String)
    after_initialize
  end

  def after_initialize
    @vname = MT::QtCore.tl_hvname(@zname) if @vname.empty?
    @labels.map! { |label| MT::QtCore.tl_hvword(label.strip, cap: true) }
    @labels.reject!(&.blank?).uniq!
  end

  # def tl_chap_info!(start : Int32 = 1, limit : Int32 = @chap_count)
  #   self.crepo.update_vinfos!(start: start, limit: limit)
  # end

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix)
    @mtime = mtime if @mtime < mtime

    @chap_count = chmax if @chap_count < chmax
    self.crepo.chmax = @chap_count

    query = @@schema.update_stmt(%w{chap_count mtime})
    @@db.exec(query, @chap_count, @mtime, @id)
  end

  INC_VIEW_COUNT_SQL = <<-SQL
    update upstems set view_count = view_count + 1
    where id = $1
    returning view_count
    SQL

  def inc_view_count!
    @view_count = @@db.query_one(INC_VIEW_COUNT_SQL, @id, as: Int32)
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

  def self.build_select_sql(guard : Int32 = 4, uname : String? = nil,
                            wn_id : Int32? = nil, label : String? = nil,
                            title : String? = nil, order : String = "mtime")
    args = [guard] of String | Int32

    query = String.build do |sql|
      sql << "select * from #{@@schema.table} where guard <= $1"

      if uname
        args << uname
        sql << " and sname = '@' || $2"
      end

      if wn_id
        args << wn_id
        sql << " and wn_id = $#{args.size}"
      end

      if label
        args << label
        sql << " and $#{args.size} = any(labels)"
      end

      if title
        args << title
        field = title =~ /\p{Han}/ ? "zname" : "vname"
        sql << " and #{field} ilike '%' || $#{args.size} || '%'"
      end

      case order
      when "mtime" then sql << " order by mtime desc"
      when "chmax" then sql << " order by chap_count desc"
      else              sql << " order by id desc"
      end

      sql << " limit $#{args.size &+ 1} offset $#{args.size &+ 2}"
    end

    {query, args}
  end
end
