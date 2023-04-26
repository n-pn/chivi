require "crorm"
require "crorm/sqlite3"

class MT::MtDefn
  include Crorm::Model
  @@table = "defns"

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

  def self.repo(dname : String | Int32)
    SQ3::Repo.new(db_path(dname), init_sql, ttl: 3.minutes)
  end

  @[AlwaysInline]
  def self.db_path(dname : String | Int32)
    "var/mtdic/fixed/#{dname}.dic"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/mt_defn.sql") }}
  end
end
