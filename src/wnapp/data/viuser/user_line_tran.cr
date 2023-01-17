require "json"
require "sqlite3"

class WN::ChLineTran
  include DB::Serializable
  include JSON::Serializable

  def self.db_path
    "var/chaps/trans.db"
  end

  def self.open_db
    DB.open("sqlite3:#{db_path}") { |db| yield db }
  end

  init_db unless File.exists?(db_path)

  def self.init_db
    open_db do |db|
      db.exec <<-SQL
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
    end
  end

  def self.insert(input : Hash(String, DB::Any))
    fields = input.keys.join(", ")
    values = input.values
    holder = Array.new(values.size, "?").join(", ")
    open_db &.exec("insert into trans(#{fields}) values (#{holder})", args: values)
  end

  # property id : Int32 = 0

  property uname : String, sname : String
  property s_bid : Int32, s_cid : Int32
  property ch_no : Int32, cpart : Int32

  property l_id : Int32, orig : String, tran : String

  property ctime : Int64 = Time.utc.to_unix
  property _flag = 0

  def initialize(@uname, @sname,
                 @s_bid, @s_cid,
                 @ch_no, @cpart,
                 @l_id, @orig, @tran,
                 @_flag = 0)
  end

  def create!
    fields = [] of String
    values = [] of DB::Any

    {% for ivar in @type.instance_vars %}
      field = {{ivar.name.stringify}}
      value = @{{ivar.name.id}}

      fields << field
      values << value
    {% end %}

    self.class.open_db do |db|
      holder = Array.new(values.size, "?").join(", ")
      db.exec("insert into trans(#{fields.join(", ")}) values (#{holder})", args: values)
    end
  end
end
