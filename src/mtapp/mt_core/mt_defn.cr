require "crorm"
require "sqlite3"

class MT::MtDefn
  def self.db(dname : String)
    open_db(db_path(dname), init_sql)
  end

  @[AlwaysInline]
  def self.db_path(dname : String)
    "var/mtdic/fixed/#{dname}.dic"
  end

  class_getter init_sql : String = {{ read_file("#{__DIR__}/mt_defn.sql") }}

  ###

  include Crorm::Model
  schema "defns"

  field d_id : Int32 = 0
  field zstr : String = ""

  field vstr : String = ""
  field vmap : String = ""

  field upos : String = ""
  field xpos : String = ""
  field feat : String = ""

  field _fmt : Int16 = 0_i16
  field _wsr : Int16 = 2_i16 # word segmentation rank
  field _ver : Int16 = 0_i16

  field mtime : Int32 = 0
  field uname : String = ""

  field _flag : Int16 = 0_i16

  ###
end
