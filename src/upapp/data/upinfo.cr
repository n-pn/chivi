require "../../mt_ai/core/qt_core"
require "../../_data/_data"

class UP::Upinfo
  class_getter db : DB::Database = PGDB

  ###

  include Crorm::Model
  schema "upinfos", :postgres, strict: false

  field id : Int32, pkey: true, auto: true

  field viuser_id : Int32 = 0
  field wninfo_id : Int32? = nil

  field zname : String = ""
  field vname : String = ""
  field uslug : String = ""

  field vintro : String = ""
  field labels : Array(String) = [] of String

  field mtime : Int64 = Time.utc.to_unix
  field guard : Int16 = 0

  field chap_count : Int32 = 0
  field word_count : Int32 = 0

  timestamps

  def after_initialize
    @labels.map! { |label| MT::QtCore.tl_hvword(label.strip, cap: true) }
    @labels.reject!(&.blank?).uniq!

    @vname = MT::QtCore.tl_hvname(zname) if @vname.empty?
    @uslug = TextUtil.tokenize(@vname).join(&.[0])
  end

  ##

  def self.find(id : Int32, uname : Nil = nil)
    query = @@schema.select_stmt(&.<< "where id = $1 limit 1")
    self.db.query_one?(query, as: self)
  end

  def self.find(id : Int32, uname : String)
    query = @@schema.select_stmt do |sql|
      sql << <<-SQL
        where id = $1 and viuser_id = (select id from viusers where uname = $2)
        limit 1
        SQL
    end

    self.db.query_one?(query, as: self)
  end

  def self.get_all(uname : String, limit = 50, offset = 0)
    query = @@schema.select_stmt do |sql|
      sql << <<-SQL
        where viuser_id = (select id from viusers where uname = $1)
        order by mtime desc
        limit $2 offset $3
        SQL
    end

    self.db.query_all(query, uname, limit, offset, as: self)
  end

  def self.get_all(limit = 50, offset = 0)
    query = @@schema.select_stmt do |sql|
      sql << <<-SQL
        order by mtime desc
        limit $1 offset $2
        SQL
    end

    self.db.query_all(query, limit, offset, as: self)
  end
end
