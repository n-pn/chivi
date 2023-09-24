require "../../mt_ai/core/qt_core"
require "../../_data/_base"

class UP::Upinfo
  include Crorm::Model
  schema "upinfos", :postgres, strict: false

  field id : Int32, pkey: true, auto: true

  field viuser_id : Int32 = 0
  field wninfo_id : Int32? = nil

  field zname : String = ""
  field vname : String = ""
  field uslug : String = ""

  field vintro : String = ""
  field labels : Array(String) = [] of String

  field mtime : Int64 = Time.utc.to_unix
  field guard : Int16 = 0

  field chap_count : Int32 = 0
  field word_count : Int32 = 0

  timestamps

  def zname=(@zname : String)
    @vname = MT::QtCore.tl_hvname(zname)
    @uslug = @vname.split.map(&.[0]).join
  end
end
