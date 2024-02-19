require "../../mt_ai/core/qt_core"

require "../_base"
require "./wninfo"

class CV::Author
  include Crorm::Model
  schema "authors", :postgres, strict: false

  field au_zh : String
  field au_vi : String
  field au_hv : String
  field au_en : String

  field vdesc : String = ""
  field book_count : Int32 = 0

  field _flag : Int16 = 0

  # field vi_uc : String = "" # user provided
  # field vi_ms : String = "" # bing translator
  # field vi_gg : String = "" # google translator
  # field vi_bd : String = "" # baidu translator

  # field en_uc : String = "" # user provided
  # field en_dl : String = "" # deepl translator
  # field en_ms : String = "" # bing translator
  # field en_gg : String = "" # google translator
  # field en_bd : String = "" # baidu translator

  timestamps

  ####################

  VNAMES = {} of String => String

  def self.get_vname(au_zh : String) : String
    VNAMES[au_zh] ||= begin
      stmt = <<-SQL
        select coalesce(nullif(au_vi, ''), au_hv)
        from authors where au_zh = $1 limit 1
        SQL
      PGDB.query_one?(stmt, au_zh, as: String) || au_zh
    end
  end

  def self.upsert!(au_zh : String, au_vi : String? = nil) : Author
    au_hv = MT::QtCore.tl_hvname(au_zh)
    ctime = Time.utc

    PGDB.query_one <<-SQL, au_zh, au_hv, au_vi || au_hv, ctime, au_vi, as: Author
      insert into authors(au_zh, au_hv, au_vi, updated_at)
      values ($1, $2, $3, $4)
      on conflict(au_zh) do update set
        au_hv = excluded.au_hv,
        au_vi = coalesce($5, authors.au_vi),
        updated_at = excluded.updated_at
      returning *
      SQL
  end

  # puts upsert!("囧囧的白日梦").to_pretty_json
  # puts upsert!("剑士桐人０", "Kiếm Sĩ Đồng Nhân 0").to_pretty_json
  # puts get_au_vi("剑士桐人０")
end
