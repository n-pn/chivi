require "crorm"
require "../../_util/chap_util"

class RD::Czdata
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS czdata(
      ch_no integer NOT NULL primary key,
      s_cid integer NOT NULL default 0,
      --
      title text NOT NULL DEFAULT '',
      chdiv text NOT NULL DEFAULT '',
      --
      ztext text NOT NULL default '',
      mtime integer NOT NULL DEFAULT 0
    ) strict;
    SQL

  CZ_DIR = "/2tb/zroot/zdata"

  @[AlwaysInline]
  def self.db_path(sname : String, sn_id : String | Int32)
    "#{CZ_DIR}/#{sname}/#{sn_id}-zdata.db3"
  end

  ###

  include Crorm::Model
  schema "czdata", :sqlite, multi: true

  field ch_no : Int32 = 0, pkey: true
  field s_cid : Int32 = 0

  field title : String = ""
  field chdiv : String = ""

  field mtime : Int64 = 0_i64
  field ztext : String = ""

  def initialize(@ch_no, @s_cid = ch_no, @ztext = "", @title = "", @chdiv = "", @mtime = 0_i64)
  end

  ###
end
