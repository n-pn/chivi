require "../_base"
require "../../mt_ai/core/qt_core"

class CV::Btitle
  include Crorm::Model
  schema "btitles", :postgres, strict: false

  field bt_zh : String, pkey: true # chinese
  field bt_hv : String = ""        # hanviet
  field bt_vi : String = ""        # vietnamese
  field bt_en : String = ""        # english name

  field vi_uc : String = "" # user provided
  field vi_qt : String = "" # from qt_v1
  field vi_ms : String = "" # bing translator
  field vi_gg : String = "" # google translator
  field vi_bd : String = "" # baidu translator

  field en_uc : String = "" # user provided
  field en_dl : String = "" # deepl translator
  field en_ms : String = "" # bing translator
  field en_gg : String = "" # google translator
  field en_bd : String = "" # baidu translator

  def initialize(@bt_zh)
  end

  ####

  VNAMES = {} of String => {String, String}

  def self.get_names(bt_zh : String) : {String, String}
    VNAMES[bt_zh] ||= begin
      stmt = <<-SQL
        select coalesce(nullif(bt_vi, ''), bt_hv), bt_hv
        from btitles where bt_zh = $1 limit 1
        SQL

      PGDB.query_one?(stmt, bt_zh, as: {String, String}) || begin
        bt_hv = MT::QtCore.tl_hvname(bt_zh)
        spawn upsert!(bt_zh, bt_hv: bt_hv)

        {bt_hv, bt_hv}
      end
    end
  end

  def self.upsert!(bt_zh : String,
                   bt_vi : String? = nil,
                   bt_hv : String = MT::QtCore.tl_hvname(bt_zh)) : self
    PGDB.query_one <<-SQL, bt_zh, bt_vi || bt_hv, bt_hv, bt_vi, as: Btitle
      insert into btitles(bt_zh, bt_vi, bt_hv)
      values ($1, $2, $3)
      on conflict(bt_zh) do update set
        bt_hv = excluded.bt_hv,
        bt_vi = coalesce($4, btitles.bt_vi)
      returning *
      SQL
  end
end
