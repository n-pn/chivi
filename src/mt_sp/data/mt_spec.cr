require "crorm"

class SP::MtSpec
  class_getter db_path = "var/mtdic/specs.db3"

  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS specs (
      "zstr" varchar not null primary key,
      "orig" varchar not null default '',

      "tok_gold" varchar not null default '',
      "pos_gold" varchar not null default '',
      "con_gold" varchar not null default '',

      "tok_auto" varchar not null default '',
      "pos_auto" varchar not null default '',
      "con_auto" varchar not null default '',

      "tok_temp" varchar NOT NULL DEFAULT '',
      "pos_temp" varchar not null default '',
      "con_temp" varchar not null default '',

      "vie_user" varchar not null default '',
      "vie_bing" varchar not null default '',
      "vie_goog" varchar not null default '',

      "eng_user" varchar not null default '',
      "eng_bing" varchar not null default '',
      "eng_deep" varchar not null default '',

      "tok_flag" integer NOT NULL DEFAULT 0,
      "pos_flag" integer NOT NULL DEFAULT 0,
      "con_flag" integer NOT NULL DEFAULT 0,

      "vie_flag" integer NOT NULL DEFAULT 0,
      "eng_flag" integer NOT NULL DEFAULT 0,

      "sdict" varchar not null default 'testing',
      "uname" varchar not null default '',
      "mtime" bigint not null default 0
    );
    SQL

  ###

  include Crorm::Model
  schema "specs", :sqlite, strict: false

  field zstr : String, pkey: true
  field orig : String

  field tok_gold : String = ""
  field tok_auto : String = ""
  field tok_temp : String = ""
  field tok_flag : Int32 = 0

  field pos_gold : String = ""
  field pos_auto : String = ""
  field pos_temp : String = ""
  field pos_flag : Int32 = 0

  field con_gold : String = ""
  field con_auto : String = ""
  field con_temp : String = ""
  field con_flag : Int32 = 0

  field vie_user : String = ""
  field vie_bing : String = ""
  field vie_goog : String = ""
  field vie_flag : Int32 = 0

  field eng_user : String = ""
  field eng_bing : String = ""
  field eng_deep : String = ""
  field eng_flag : Int32 = 0

  field pdict : String = "testing"
  field uname : String = ""
  field mtime : Int64 = 0

  def initialize(@zstr, @orig)
  end
end
