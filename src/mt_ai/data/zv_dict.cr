require "./zv_term"
require "./mt_data"

class MT::ZvDict
  class_getter db : ::DB::Database = ZR_DB

  ######

  include Crorm::Model
  schema "zvdict", :postgres

  field name : String, pkey: true
  field kind : Int16 = 0_i16
  field d_id : Int32 = 0 # unique by kind

  field p_min : Int32 = 2
  field label : String = ""
  field brief : String = ""

  field total : Int32 = 0
  field mtime : Int32 = 0
  field users : Array(String) = [] of String

  def initialize(@name, kind : DictKind, d_id : Int32)
    @kind = kind.value
    @d_id = d_id * 10 + @kind

    case kind
    when .system? then @p_min = 2
    when .global? then @p_min = 1
    else               @p_min = 0
    end
  end

  @[AlwaysInline]
  def load_term(cpos : String, zstr : String)
    ZvTerm.init(d_id: @d_id, cpos: cpos, zstr: zstr)
  end

  #######

  def add_term(zterm : ZvTerm, fresh : Bool = true, persist : Bool = true)
    @total += 1 if fresh
    @mtime = zterm.mtime

    mdata = MtData.new(zterm)
    spawn mdata.save!

    HashDict.add_term(@name, zterm.zstr, zterm.ipos, mdata.mt_term)
    # TrieDict.add_term(@name, zterm.zstr, mdata.ws_term)

    self.upsert! if persist
  end

  def delete_term(zterm : ZvTerm, fresh : Bool = true, persist : Bool = true)
    HashDict.delete_term(@name, zterm.zstr, zterm.ipos)
    # TrieDict.delete_term(@name, zterm.zstr)

    return unless fresh
    @total -= 1

    return unless persist

    MtData.delete(@d_id, zterm.ipos, zterm.zstr)
    ZvTerm.delete(@d_id, zterm.ipos, zterm.zstr)

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

      jb.field "p_min", @p_min
      jb.field "label", @label
      jb.field "brief", @brief

      jb.field "total", @total
      jb.field "mtime", TimeUtil.cv_utime(@mtime)
      # jb.field "users", @users
    end
  end

  ###

  DB_CACHE = {} of String => self

  class_getter regular : self { load!("regular") }
  class_getter essence : self { load!("essence") }
  class_getter suggest : self { load!("suggest") }

  def self.load!(name : String)
    DB_CACHE[name] ||= find(name) || begin
      case name
      when .starts_with?("wn")
        new(name, kind: :wnovel, d_id: name[2..].to_i).upsert!
      when .starts_with?("up")
        new(name, kind: :userpj, d_id: name[2..].to_i).upsert!
      when .starts_with?("pd")
        new(name, kind: :public, d_id: name[2..].to_i).upsert!
      when .starts_with?("qt")
        new(name, kind: :userqt, d_id: name[2..].to_i).upsert!
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
      query = "#{COUNT_SQL} where kind = #{DictKind::Wnovel.value}"
    when "up"
      query = "#{COUNT_SQL} where kind = #{DictKind::Userpj.value}"
    when "pd"
      query = "#{COUNT_SQL} where kind = #{DictKind::Public.value}"
    when "qt"
      query = "#{COUNT_SQL} where kind = #{DictKind::Userqt.value}"
    when "tm"
      query = "#{COUNT_SQL} where kind = #{DictKind::Themes.value}"
    else
      query = "#{COUNT_SQL} where kind < #{DictKind::Themes.value}"
    end

    @@db.query_one(query, as: Int32)
  end

  def self.fetch_all(kind : String, limit = 25, offset = 0) : Array(self)
    case kind
    when "wn" then fetch_all(:wnovel, limit, offset)
    when "up" then fetch_all(:userpj, limit, offset)
    when "qt" then fetch_all(:userqt, limit, offset)
    when "gd" then fetch_all(:public, limit, offset)
    when "tm" then fetch_all(:themes, limit, offset)
    else           fetch_all_core()
    end
  end

  def self.fetch_all(kind : DictKind, limit = 50, offset = 0)
    self.get_all kind.value, limit, offset do |sql|
      sql << " where kind = $1 order by mtime desc, total desc limit $2 offset $3"
    end
  end

  def self.fetch_all_core
    self.get_all(&.<< " where kind < #{DictKind::Themes.value} order by d_id asc")
  end

  def self.init_wn_dict!(wn_id : Int32, bname : String, db = self.db)
    dict = self.new("wn#{wn_id}", :wnovel, wn_id)
    dict.tap(&.set_label(bname)).upsert!(db: db)
  end

  def self.init_up_dict!(up_id : Int32, bname : String, db = self.db)
    dict = self.new("up#{up_id}", :userpj, up_id)
    dict.tap(&.set_label(bname)).upsert!(db: db)
  end
end
