require "crorm"
require "../_data"
require "./dtopic"
require "./rpnode"

class CV::Rproot
  enum Kind : Int16
    Global = 0
    Dtopic = 1

    Author = 10
    Wninfo = 11
    Wnseed = 12
    Wnchap = 13

    Viuser = 20
    Vilist = 21
    Vicrit = 22

    Ysuser = 120
    Yslist = 121
    Yscrit = 122

    def vstr
      case self
      in .global? then "thảo luận chung"
      in .dtopic? then "chủ đề thảo luận"
        ##
      in .author? then "trang tác giả"
      in .wninfo? then "bình luận truyện"
      in .wnseed? then "bình luận nguồn"
      in .wnchap? then "bình luận chương"
        ##
      in .vilist? then "thư đơn"
      in .vicrit? then "đánh giá truyện"
      in .viuser? then "trang người dùng"
        ##
      in .yslist? then "thư đơn yousuu"
      in .yscrit? then "đánh giá yousuu"
      in .ysuser? then "người dùng yousuu"
        ##
      end
    end

    def self.value(kind : self)
      kind.value
    end

    def self.parse_ruid(str : String)
      case str
      when "xx" then Global
      when "gd" then Dtopic
      when "dt" then Dtopic
      when "na" then Author
      when "ni" then Wninfo
      when "ns" then Wnseed
      when "nc" then Wnchap
      when "vc" then Vicrit
      when "vl" then Vilist
      when "vu" then Viuser
      when "yc" then Yscrit
      when "yl" then Yslist
      when "yu" then Ysuser
      else           parse(str)
      end
    end
  end

  include Crorm::Model
  include DB::Serializable::NonStrict

  class_getter table = "rproots"
  class_getter db : DB::Database = PGDB

  field id : Int32 = 0, auto: true

  field kind : Int16 = 0_i16, primary: true
  field ukey : String = "", primary: true

  field viuser_id : Int32 = 0
  field dboard_id : Int32 = 0

  field _type : String = ""
  field _name : String = ""
  field _desc : String = ""
  field _link : String = ""

  field repl_count : Int32 = 0
  field view_count : Int32 = 0
  field like_count : Int32 = 0
  field star_count : Int32 = 0

  field last_seen_at : Time = Time.utc
  field last_repl_at : Time = Time.utc

  field created_at : Time = Time.utc
  field updated_at : Time = Time.utc

  field deleted_at : Time? = nil
  field deleted_by : Int32? = nil

  def initialize(dtopic : Dtopic)
    @viuser_id = dtopic.viuser_id
    @dboard_id = dtopic.nvinfo_id

    @kind = Kind.value(:dtopic)
    @ukey = "#{dtopic.id}"

    @_type = "chủ đề"
    @_link = "/gd/t-#{dtopic.id}-#{dtopic.tslug}"
    @_name = dtopic.title
    @_desc = dtopic.brief

    @last_seen_at = @last_repl_at = dtopic.updated_at

    @created_at = dtopic.created_at
    @updated_at = dtopic.updated_at
  end

  def initialize(wninfo : Wninfo)
    @viuser_id = 1
    @dboard_id = wninfo.id

    @kind = Kind::Wninfo.value
    @ukey = "#{wninfo.id}"

    @_type = "bình luận truyện"
    @_link = "/wn/#{wninfo.id}-#{wninfo.bslug}/bants"

    @_name = wninfo.vname
    @_desc = TextUtil.truncate(wninfo.bintro, 100)

    @repl_count = 0

    @created_at = wninfo.created_at
    @updated_at = wninfo.updated_at
  end

  def initialize(vicrit : Vicrit)
    @viuser_id = vicrit.viuser_id
    @dboard_id = vicrit.nvinfo_id

    @kind = Kind::Vicrit.value
    @ukey = "#{vicrit.id}"

    @_type = "đánh giá truyện"
    @_link = "/uc/v#{vicrit.id}"

    @_name = "Đánh giá của [@#{Viuser.get_uname(vicrit.viuser_id)}] cho bộ truyện [#{Wninfo.get_vname(vicrit.nvinfo_id)}]"
    @_desc = TextUtil.truncate(vicrit.itext, 100)

    @repl_count = 0
    @created_at = vicrit.created_at
    @updated_at = vicrit.updated_at
  end

  def initialize(vilist : Vilist)
    @viuser_id = vilist.viuser_id
    @dboard_id = 0

    @kind = Kind::Vilist.value
    @ukey = "#{vilist.id}"

    @_type = "thư đơn"
    @_link = "/ul/v#{vilist.id}-#{vilist.tslug}"

    @_name = vilist.title
    @_desc = TextUtil.truncate(vilist.dtext, 100)

    @repl_count = 0
    @created_at = vilist.created_at
    @updated_at = vilist.updated_at
  end

  def initialize(wn_id : Int32, ch_no : Int32, sname : String)
    @kind = Kind::Wnchap.value
    @ukey = "#{wn_id}:#{ch_no}:#{sname}"

    @viuser_id = 1
    @dboard_id = wn_id

    @_type = "bình luận chương"
    @_link = "/gd/ch#{wn_id}-#{sname}-#{ch_no}"

    @_name = "#{sname}-#{ch_no}"
    @_desc = ""
  end

  def initialize(kind : Kind, @ukey : String,
                 @viuser_id = -1, @dboard_id = -1,
                 @_type = "", @_link = "", @_name = "")
    @kind = kind.value
  end

  def fix_data
    repls = Rpnode.get_all(rproot: id)
    @repl_count = repls.size
    @last_repl_at = Time.unix(repls.max_of(&.utime))
  end

  def rkey
    case Kind.new(@kind)
    in .global? then "xx:#{@ukey}"
    in .dtopic? then "dt:#{@ukey}"
    in .wninfo? then "ni:#{@ukey}"
    in .author? then "na:#{@ukey}"
    in .wnseed? then "ns:#{@ukey}"
    in .wnchap? then "nc:#{@ukey}"
    in .vicrit? then "vc:#{@ukey}"
    in .vilist? then "vl:#{@ukey}"
    in .viuser? then "vu:#{@ukey}"
    in .yscrit? then "yc:#{@ukey}"
    in .yslist? then "yl:#{@ukey}"
    in .ysuser? then "yu:#{@ukey}"
    end
  end

  def do_upsert!(db = @@db)
    fields = @@db_fields.reject("id")

    upsert_stmt = String.build do |sql|
      sql << "insert into " << @@table << '('
      fields.join(sql, ", ")
      sql << ") values ("
      (1..fields.size).join(sql, ", ") { |i, _| sql << '$' << i }
      sql << ") on conflict(kind, ukey) do update set "

      fields = fields.reject(&.in?(%w(kind ukey)))
      fields.join(sql, ", ") { |field, _| sql << field << " = excluded." << field }
      sql << " returning *"
    end

    Log.info { upsert_stmt }
    db.query_one upsert_stmt, *self.db_values, as: Rproot
  end

  ####

  def self.find!(id : Int32)
    @@db.query_one <<-SQL, id, as: Rproot
      select * from #{@@table}
      where id = $1 limit 1
      SQL
  end

  def self.find(kind : Kind, ukey : String)
    @@db.query_one? <<-SQL, kind.value, ukey, as: Rproot
      select * from #{@@table}
      where kind = $1 and ukey = $2 limit 1
      SQL
  end

  def self.find!(kind : Kind, ukey : String)
    find(kind, ukey) || raise "Thread không tồn tại!"
  end

  def self.bump_on_new_reply!(id : Int32, last_repl_at : Time = Time.utc)
    kind, ukey = @@db.query_one <<-SQL, last_repl_at, id, as: {Int16, String}
      update #{@@table} set repl_count = repl_count + 1, last_repl_at = $1
      where id = $2
      returning kind, ukey
      SQL

    case Kind.new(kind)
    when .vicrit? then Vicrit.inc_repl_count!(ukey.to_i)
    when .dtopic? then Dtopic.inc_repl_count!(ukey.to_i)
    end
  end

  def self.load!(ruid : String)
    kind, ukey = ruid.split(':', 2)

    if kind == "id"
      find!(ukey.to_i)
    else
      kind = Kind.parse_ruid(kind)
      find(kind, ukey) || init(kind, ukey).do_upsert!
    end
  end

  def self.init(kind : Kind, ukey : String)
    case kind
    when .dtopic? then new(Dtopic.find!(ukey.to_i))
    when .wninfo? then new(Wninfo.load!(ukey.to_i))
    when .vicrit? then new(Vicrit.load!(ukey.to_i))
    when .vilist? then new(Vilist.load!(ukey.to_i))
    when .wnseed?
      wn_id, sname = ukey.split(':', 2)
      wninfo = Wninfo.load!(wn_id.to_i)

      new(
        kind: kind, ukey: ukey,
        dboard_id: wninfo.id,
        _type: "bình luận",
        _name: "nguồn [#{sname}] bộ truyện [#{wninfo.vname}]",
        _link: "/wn/#{wninfo.id}-#{wninfo.bslug}/chaps/#{sname}"
      )
    when .wnchap?
      wn_id, ch_no, sname = ukey.split(':', 3)
      wninfo = Wninfo.load!(wn_id.to_i)

      new(
        kind: kind, ukey: ukey,
        dboard_id: wninfo.id,
        _type: "bình luận",
        _name: "chương [#{ch_no}] nguồn [#{sname}] bộ truyện [#{wninfo.vname}]",
        _link: "/wn/#{wninfo.id}-#{wninfo.bslug}/chaps/#{sname}/#{ch_no}"
      )
    when .global?
      new(kind: kind, ukey: ukey, _type: "thảo luận", _name: ukey, _link: "")
    else
      raise "unsuported kind: #{kind}/#{ukey}"
    end
  end

  def self.glob(ids : Enumerable(Int32))
    @@db.query_all <<-SQL, ids, as: self
      select * from #{@@table}
      where id = any($1)
      SQL
  end
end
