require "../_base"
require "../../mt_ai/core/qt_core"

class CV::Btitle
  include Crorm::Model
  schema "btitles", :postgres, strict: false

  field name_zh : String = "" # chinese title
  field name_hv : String = "" # hanviet title
  field name_vi : String = "" # localization

  VNAMES = {} of String => {String, String}

  def self.get_names(name_zh : String) : {String, String}
    VNAMES[name_zh] ||= begin
      stmt = <<-SQL
        select coalesce(nullif(name_vi, ''), name_hv), name_hv
        from btitles where name_zh = $1 limit 1
        SQL

      PGDB.query_one?(stmt, name_zh, as: {String, String}) || begin
        name_hv = MT::QtCore.tl_hvname(name_zh)
        spawn upsert!(name_zh, name_hv: name_hv)

        {name_hv, name_hv}
      end
    end
  end

  def self.upsert!(name_zh : String,
                   name_vi : String? = nil,
                   name_hv = MT::QtCore.tl_hvname(name_zh)) : self
    PGDB.query_one <<-SQL, name_zh, name_vi || name_hv, name_hv, name_vi, as: Btitle
      insert into btitles(name_zh, name_vi, name_hv)
      values ($1, $2, $3)
      on conflict(name_zh) do update set
        name_hv = excluded.name_hv,
        name_vi = coalesce($4, btitles.name_vi)
      returning *
      SQL
  end
end
