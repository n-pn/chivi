require "../../mt_ai/core/qt_core"

require "../_base"
require "./wninfo"

class CV::Author
  include Crorm::Model
  schema "authors", :postgres, strict: false

  field zname : String
  field vname : String

  field vdesc : String = ""
  field book_count : Int32 = 0

  timestamps

  ####################

  VNAMES = {} of String => String

  def self.get_vname(zname : String) : String
    VNAMES[zname] ||= begin
      stmt = "select vname from authors where zname = $1 limit 1"
      PGDB.query_one?(stmt, zname, as: String) || zname
    end
  end

  def self.upsert!(zname : String, vname : String? = nil) : Author
    xname = vname || MT::QtCore.tl_hvname(zname)
    ctime = Time.utc

    PGDB.query_one <<-SQL, zname, xname, ctime, ctime, vname, as: Author
      insert into authors(zname, vname, created_at, updated_at)
      values ($1, $2, $3, $4)
      on conflict(zname) do update set
        vname = coalesce($5, authors.vname),
        updated_at = excluded.updated_at
      returning *
      SQL
  end

  # puts upsert!("囧囧的白日梦").to_pretty_json
  # puts upsert!("剑士桐人０", "Kiếm Sĩ Đồng Nhân 0").to_pretty_json
  # puts get_vname("剑士桐人０")
end
