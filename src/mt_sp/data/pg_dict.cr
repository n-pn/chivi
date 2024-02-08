require "../../_data/zr_db"

class SP::PgDict
  class_getter db : ::DB::Database = ZR_DB

  ######

  include Crorm::Model
  schema "zvdict", :postgres

  field name : String, pkey: true
  field kind : Int16 = 0_i16
  field d_id : Int32 = 0 # unique by kind

  field p_min : Int32 = 1
  field label : String = ""
  field brief : String = ""

  field total : Int32 = 0
  field mtime : Int32 = 0
  field users : Array(String) = [] of String

  def initialize(@name, @kind, d_id : Int32)
    @d_id = d_id * 10 + kind

    case kind
    when 0 then @p_min = 3
    when 1 then @p_min = 2
    when 8 then @p_min = 0
    else        @p_min = 1
    end
  end

  def p_min
    case @kind
    when 0 then 3
    when 1 then 2
    when 8 then 0
    else        1
    end
  end

  @[AlwaysInline]
  def load_term(cpos : String, zstr : String)
    PgDefn.init(d_id: @d_id, cpos: cpos, zstr: zstr)
  end

  #######

  def add_term(zterm : PgDefn, fresh : Bool = true, persist : Bool = true)
    @total += 1 if fresh
    @mtime = zterm.mtime
    self.upsert! if persist
  end

  def delete_term(zterm : PgDefn, fresh : Bool = true, persist : Bool = true)
    # HashDict.delete_term(@name, zterm.zstr, zterm.ipos)
    # TrieDict.delete_term(@name, zterm.zstr)

    return unless fresh
    @total -= 1

    return unless persist

    # MtData.delete(@d_id, zterm.ipos, zterm.zstr)
    # PgDefn.delete(@d_id, zterm.ipos, zterm.zstr)

    self.upsert!
  end

  #######

  def gen_brief(label : String)
    "Từ điển riêng cho [#{label}] (#{DictKind.new(@kind).vname})"
  end

  def set_label(@label, @brief = gen_brief(label))
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "name", @name
      jb.field "kind", @kind
      jb.field "d_id", @d_id

      jb.field "p_min", self.p_min
      jb.field "label", @label
      jb.field "brief", @brief

      jb.field "total", @total
      jb.field "mtime", TimeUtil.cv_utime(@mtime)
      # jb.field "users", @users
    end
  end

  ###

  DB_CACHE = {} of String => self

  def self.load!(name : String)
    DB_CACHE[name] ||= find(name) || begin
      case name
      when .starts_with?("wn")
        new(name, kind: 5, d_id: name[2..].to_i).upsert!
      when .starts_with?("up")
        new(name, kind: 6, d_id: name[2..].to_i).upsert!
      when .starts_with?("pd")
        new(name, kind: 7, d_id: name[2..].to_i).upsert!
      when .starts_with?("qt")
        new(name, kind: 8, d_id: name[2..].to_i).upsert!
      else
        raise "dict name not allowed: #{name}"
      end
    end
  end

  def self.find(name : String) : self | Nil
    self.get(name, db: @@db, &.<< " where name = $1")
  end

  def self.find!(name : String) : self
    self.get!(name, db: @@db, &.<< " where name = $1")
  end

  ####

  COUNT_SQL = "select coalesce(count(*)::int, 0) from #{@@schema.table} "

  def self.count(kind : String) : Int32
    case kind
    when "wn"
      query = "#{COUNT_SQL} where kind = 5"
    when "up"
      query = "#{COUNT_SQL} where kind = 6"
    when "pd"
      query = "#{COUNT_SQL} where kind = 7"
    when "qt"
      query = "#{COUNT_SQL} where kind =8"
    when "dm"
      query = "#{COUNT_SQL} where kind = 4"
    else
      query = "#{COUNT_SQL} where kind < 4"
    end

    @@db.query_one(query, as: Int32)
  end

  def self.fetch_all(kind : String, limit = 25, offset = 0) : Array(self)
    case kind
    when "wn" then fetch_all(5, limit, offset)
    when "up" then fetch_all(6, limit, offset)
    when "qt" then fetch_all(8, limit, offset)
    when "gd" then fetch_all(7, limit, offset)
    when "dm" then fetch_all(4, limit, offset)
    else           fetch_all_core()
    end
  end

  def self.fetch_all(kind : Int16, limit = 50, offset = 0)
    self.get_all kind, limit, offset do |sql|
      sql << " where kind = $1 order by mtime desc, total desc limit $2 offset $3"
    end
  end

  def self.fetch_all_core
    self.get_all(&.<< " where kind < 4 order by d_id asc")
  end

  def self.init_wn_dict!(wn_id : Int32, bname : String, db = self.db)
    dict = self.new("wn#{wn_id}", 5, wn_id)
    dict.tap(&.set_label(bname)).upsert!(db: db)
  end

  def self.init_up_dict!(up_id : Int32, bname : String, db = self.db)
    dict = self.new("up#{up_id}", 6, up_id)
    dict.tap(&.set_label(bname)).upsert!(db: db)
  end
end
