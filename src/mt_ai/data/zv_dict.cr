require "../../_data/zr_db"
require "./zv_term"

class MT::ZvDict
  enum Kind : Int16
    System = 0 # system dict
    Global = 1 # regular dict

    Themes = 4 # common themes
    Wnovel = 5 # use for chivi official book series
    Userpj = 6 # use for user created series
    Public = 7 # use for public domain series
    Userqt = 8 # unique for each user, use for every quick trans posts

    def vname
      case self
      when System then "hệ thống"
      when Global then "thông dụng"
      when Themes then "văn cảnh riêng"
      when Wnovel then "bộ truyện chữ"
      when Userpj then "sưu tầm cá nhân"
      when Public then "sở hữu công cộng"
      when Userqt then "dịch nhanh cá nhân"
      end
    end

    def self.p_min(dname : String)
      case dname
      when /^(book|wn|up|qt|tm|pd)/  then 0
      when /regular|combine|suggest/ then 1
      when .ends_with?("pair")       then 1
      else                                2
      end
    end
  end

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

  def initialize(@name, kind : Kind, d_id : Int32)
    @kind = kind.value
    @d_id = d_id * 10 + @kind

    case kind
    when .system? then @p_min = 2
    when .global? then @p_min = 1
    else               @p_min = 0
    end
  end

  @[DB::Field(ignore: true, auto: true)]
  getter term_hash : Hash(String, Hash(MtEpos, ZvTerm)) do
    hash = {} of String => Hash(MtEpos, ZvTerm)

    @@db.query_each "select * from zvterm where d_id = $1", @d_id do |rs|
      term = rs.read(ZvTerm)
      nest = hash[term.zstr] ||= {} of MtEpos => ZvTerm
      nest[term.ipos] = term
    end

    hash
  end

  def find_term(cpos : String, zstr : String)
    find_term(MtEpos.parse(cpos), zstr)
  end

  def find_term(ipos : MtEpos, zstr : String)
    self.term_hash[zstr]?.try(&.[ipos])
  end

  def load_term(cpos : String, zstr : String)
    ipos = MtEpos.parse(cpos)
    list = self.term_hash[zstr] ||= {} of MtEpos => ZvTerm
    list[ipos] ||= ZvTerm.new(d_id: @d_id, cpos: cpos, zstr: zstr, ipos: ipos)
  end

  #######

  def add_term(tform, uname : String = "", persist : Bool = true)
    zterm = self.load_term(cpos: tform.cpos, zstr: tform.zstr)
    fresh = zterm.mtime < 0

    zterm.add_track(uname: uname)

    @total += 1 if fresh
    @mtime = zterm.mtime

    zterm.vstr = tform.vstr
    zterm.attr = tform.attr

    zterm.plock = tform.plock

    return zterm unless persist

    self.upsert!
    zterm.upsert!
  end

  def delete_term(tform, persist : Bool = true)
    ipos = MtAttr.parse(tform.cpos)
    return unless term = self.term_hash.try(&.delete(ipos))
    return unless persist

    query = "delete from zvterm where d_id = $1, ipos = $2, zstr = $3"
    @@db.exec query, @d_id, ipos, tform.zstr

    @total -= 1
    self.upsert!
  end

  #######

  def gen_brief(label : String)
    "Từ điển riêng cho [#{label}] (#{Kind.new(@kind).vname})"
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

  COUNT_SQL = "select coalesce(count(*)::int, 0) from #{@@schema.table} "

  def self.count(kind : String) : Int32
    case kind
    when "wn"
      query = "#{COUNT_SQL} where kind = #{Kind::Wnovel.value}"
    when "up"
      query = "#{COUNT_SQL} where kind = #{Kind::Userpj.value}"
    when "pd"
      query = "#{COUNT_SQL} where kind = #{Kind::Public.value}"
    when "qt"
      query = "#{COUNT_SQL} where kind = #{Kind::Userqt.value}"
    when "tm"
      query = "#{COUNT_SQL} where kind = #{Kind::Themes.value}"
    else
      query = "#{COUNT_SQL} where kind < #{Kind::Themes.value}"
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

  def self.fetch_all(kind : Kind, limit = 50, offset = 0)
    self.get_all kind.value, limit, offset do |sql|
      sql << " where kind = $1 order by mtime desc, total desc limit $2 offset $3"
    end
  end

  def self.fetch_all_core
    self.get_all(&.<< " where kind < #{Kind::Themes.value} order by d_id asc")
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
