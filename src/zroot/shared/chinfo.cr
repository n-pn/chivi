require "crorm"
require "../../_util/text_util"

class ZR::Chinfo
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS chinfos(
      ch_no int not null PRIMARY KEY,
      ---
      rlink text NOT NULL DEFAULT '',
      spath text NOT NULL DEFAULT '',
      --
      ztitle text NOT NULL DEFAULT '',
      zchdiv text NOT NULL DEFAULT '',
      --
      cksum text NOT NULL DEFAULT ''
    );
    SQL

  def self.db_path(sname : String, sn_id : String | Int32)
    "var/zroot/chinfo/#{sname}/#{sn_id}.db3"
  end

  ###

  include Crorm::Model
  schema "chinfos", :sqlite, multi: true

  field ch_no : Int32, pkey: true

  field rlink : String = "" # full remote chapter url
  field spath : String = "" # "#{sname}/#{sn_id}/#{sc_id}"

  field ztitle : String = "" # chapter title name
  field zchdiv : String = "" # chapter chdivision (volume) name

  field cksum : String = "" # checksum when saved

  def initialize(@ch_no, @rlink, @spath, @ztitle, @zchdiv)
  end

  def create!(db)
    query = @@schema.upsert_stmt(keep_fields: %w[ch_no, rlink, spath, ztitle zchdiv])
    self.upsert(query, db: db)
  end

  def inspect(io : IO)
    {@ch_no, @spath, @ztitle, @zchdiv, @rlink}.join(io, '\t')
  end

  def txt_path
    "var/zroot/rawtxt/#{@spath}-#{@cksum}-#{@ch_no}.txt"
  end

  def saved?
    File.file?(txt_path)
  end
end
