require "sqlite3"
require "crorm/model"

class WN::ChLineTran
  class_getter db_path = "var/chaps/users/line-trans.db"

  class_getter init_sql = <<-SQL
    create table if not exists trans(
      id integer primary key,

      uname varchar default '',
      sname varchar default '',

      s_bid integer default 0,
      s_cid integer default 0,

      ch_no integer default 0,
      cpart integer default 0,

      l_id integer default 0,
      orig text default '',
      tran text default '',

      ctime integer default 0,
      _flag integer default 0
    )
    SQL
  ###

  include Crorm::Model
  schema "trans", :sqlite

  # field id : Int32, pkey: true, auto: true, skip: true

  property uname : String, sname : String
  property s_bid : Int32, s_cid : Int32
  property ch_no : Int32, cpart : Int32

  property l_id : Int32, orig : String, tran : String

  property ctime : Int64 = Time.utc.to_unix
  property _flag = 0

  def initialize(@uname, @sname, @s_bid, @s_cid, @ch_no, @cpart, @l_id, @orig, @tran, @_flag = 0)
  end
end
