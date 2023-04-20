require "../_data"
require "crorm"

class CV::Blabel
  enum Type : Int16
    Label = 0
    Genre = 1

    Utag = 5

    Orig = 10
    Seed = 11
  end

  include Crorm::Model

  class_getter table = "blabels"
  class_getter db : DB::Database = PGDB

  field name : String
  field type : Int16 = 0

  field slug : String = ""
  # field alts : Array(String) = [""]

  field book_count : Int32 = 0
  field view_count : Int32 = 0

  field created_at : Time = Time.utc
  field updated_at : Time = Time.utc

  def initialize(@name, @slug, @type)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "name", @name
      jb.field "slug", @slug
      jb.field "type", @type

      jb.field "book_count", @book_count
      jb.field "view_count", @view_count
    }
  end

  def upsert!(db = @@db)
    stmt = <<-SQL
    insert into #{@@table} (
      "name", "type", slug
      book_count, view_count,
      created_at, updated_at
    ) values ($1, $2, $3, $4, $5, $6, $7)
    on conflict ("name", "type") do update set
      slug = excluded.slug,
      book_count = excluded.book_count,
      view_count = excluded.view_count,
      updated_at = excluded.updated_at
    SQL

    db.exec stmt,
      @name, @type, @slug,
      @book_count, @view_count,
      @created_at, @updated_at
  end

  def self.fetch_all(type : Type)
    @@db.query_all <<-SQL, type.value, as: self
      select "name", "type", slug, book_count, view_count, created_at, updated_at
      from #{@@table} where "type" = $1 order by book_count desc
    SQL
  end

  ###
end
