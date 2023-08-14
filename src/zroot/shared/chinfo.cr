require "crorm"
require "../../_util/text_util"

class ZR::Chinfo
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS chinfos(
      ch_no int not null PRIMARY KEY,
      ---
      rpath text NOT NULL DEFAULT '',
      s_cid text NOT NULL DEFAULT '',
      --
      ztitle text NOT NULL DEFAULT '',
      zchdiv text NOT NULL DEFAULT ''
    );
    SQL

  def self.db_path(sname : String, sn_id : String)
    "var/zroot/wnovel/#{sname}/#{sn_id}-zchap.db3"
  end

  ###

  include Crorm::Model
  schema "chinfos", :sqlite, multi: true

  field ch_no : Int32, pkey: true

  field rlink : String = "" # relative or absolute remote path
  field spath : String = "" # remote chapter id extracted from rlink

  field ztitle : String = "" # chapter title name
  field zchdiv : String = "" # chapter chdivision (volume) name

  def initialize(@ch_no, @rlink, @spath, @ztitle, @zchdiv)
  end

  def inspect(io : IO)
    {@ch_no, @spath, @ztitle, @zchdiv, @rlink}.join(io, '\t')
  end
end
