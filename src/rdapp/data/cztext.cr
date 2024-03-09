require "crorm"

require "../../_util/chap_util"
require "../../_util/zstd_util"

class RD::Cztext
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS cztext(
      ch_no integer NOT NULL primary key,
      ztext text NOT NULL default '',
      chdiv text NOT NULL DEFAULT '',
      mtime integer NOT NULL DEFAULT 0,
      atime integer NOT NULL DEFAULT 0,
      zorig text not null default ''
    ) strict;
    SQL

  CZ_DIR = "/2tb/zroot/wn_db"

  @[AlwaysInline]
  def self.db_path(sname : String, sn_id : String | Int32)
    "#{CZ_DIR}/#{sname}/#{sn_id}-ztext.db3"
  end

  @[AlwaysInline]
  def self.db(sname : String, sn_id : String | Int32)
    self.db(db_path(sname, sn_id))
  end

  def self.db(db_path : String)
    Crorm::SQ3.new(db_path) do |db|
      zst_path = "#{db_path}.zst"

      if File.file?(zst_path)
        ZstdUtil.unzip_file(zst_path, db_path)
      else
        db.init_db(self.init_sql)
      end
    end
  end

  ###

  include Crorm::Model
  schema "cztext", :sqlite, multi: true

  field ch_no : Int32 = 0, pkey: true

  field ztext : String = ""
  field chdiv : String = ""

  field mtime : Int64 = 0_i64
  field atime : Int64 = 0_i64

  field zorig : String = ""

  def initialize(@ch_no, @ztext = "", @chdiv = "", @zorig = "")
  end

  def zchap
    "///#{chdiv}\n#{ztext}"
  end

  @[AlwaysInline]
  def self.load(db, ch_no : Int32)
    self.find_by_id(ch_no, pkey: "ch_no", db: db) || self.new(ch_no)
  end
end
