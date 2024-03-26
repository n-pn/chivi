require "crorm"

class SP::WnName
  class_getter db_path = "/srv/chivi/mt_db/wn_names.db3"

  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS wn_names (
      ztext text not null primary key,

      bt_vi text,
      bt_vu text,
      bt_qt text,
      --
      bt_en text,
      bt_eu text,
      --
      au_vi text,
      au_vu text,
      --
      au_en text,
      au_eu text,
      --
      vi_hv text,
      vi_ms text,
      vi_gg text,
      vi_bd text,
      --
      en_dl text,
      en_ms text,
      en_gg text,
      en_bd text,
      --
      _flag int not null default 0
    ) strict, without rowid;
    SQL

  include Crorm::Model
  schema "wn_names", :sqlite, strict: false

  field ztext : String, pkey: true # chinese

  field bt_vi : String? = nil
  field bt_vu : String? = nil
  field bt_qt : String? = nil

  field bt_en : String? = nil
  field bt_eu : String? = nil

  field au_vi : String? = nil
  field au_vu : String? = nil

  field au_en : String? = nil
  field au_eu : String? = nil

  field vi_hv : String? = nil
  field vi_ms : String? = nil
  field vi_gg : String? = nil
  field vi_bd : String? = nil

  field en_dl : String? = nil
  field en_ms : String? = nil
  field en_gg : String? = nil
  field en_bd : String? = nil

  field _flag : Int32 = 0

  def initialize(@ztext)
  end
end
