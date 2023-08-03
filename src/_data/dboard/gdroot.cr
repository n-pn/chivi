require "crorm"
require "../_data"
require "./dtopic"
require "./gdrepl"

# module CitextArray
#   def self.from_rs(rs)
#     rs.read(Array(Bytea)).map { |x| String.new(x) }
#   end

#   def self.to_db(data)
#     data.each(&.to_slice)
#   end
# end

class CV::Gdroot
  class_getter db : DB::Database = PGDB

  ###

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

    def self.value(kind : self)
      kind.value
    end

    def self.parse_ruid(str : String)
      case str
      when "xx" then Global
      when "gd" then Dtopic
      when "dt" then Dtopic
      when "au" then Author
      when "wn" then Wninfo
      when "ns" then Wnseed
      when "ch" then Wnchap
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
  schema "gdroots", :postgres, false

  field id : Int32 = 0, auto: true

  field kind : Int16 = 0_i16, pkey: true
  field ukey : String = "", pkey: true

  field viuser_id : Int32 = 1

  # field dboard_id : Int32 = 0

  # link to official comment page if different from default one
  # default link: `/gd/d{id}`
  # for examples:
  # - general discusion topic, the link is `/gc/t{t_id}` instead
  # - book general discussion, the link is `wn/{b_id}/gd/bants`
  # - user review page, the link is `/wn/{b_id}/uc/v{c_id}` instead

  field rlink : String = ""
  field htags : Array(String) = [] of String

  field title : String = "" # title of the discussion
  field tslug : String = "" # used when rlink is empty
  # field intro : String = "" # discussion introduction

  # original link of the discussion, use to v
  field oname : String = ""
  field olink : String = ""

  field repl_count : Int32 = 0
  field view_count : Int32 = 0
  field like_count : Int32 = 0

  field last_seen_at : Time = Time.utc
  field last_repl_at : Time = Time.utc

  field created_at : Time = Time.utc
  field updated_at : Time = Time.utc

  field deleted_at : Time? = nil
  field deleted_by : Int32? = nil

  def initialize(@id, @ukey)
  end

  def initialize(kind : Kind, @ukey)
    @kind = kind.value
  end

  def init_from(dtopic : Dtopic)
    @viuser_id = dtopic.viuser_id

    @olink = @rlink = dtopic.canonical_path

    @oname = dtopic.title.strip
    @title = "Bình luận chủ đề [#{@oname}]"
    @tslug = "binh-luan-chu-de-#{dtopic.tslug}"

    @htags << "vu:#{dtopic.viuser_id}"
    dboard_id = dtopic.nvinfo_id
    @htags << (dboard_id < 0 ? "gd:#{-dboard_id}" : "wn:#{dboard_id}")

    self
  end

  def init_from(vilist : Vilist)
    @viuser_id = vilist.viuser_id

    @olink = vilist.canonical_path

    @oname = vilist.title
    @title = "Bình luận chung thư đơn: #{@oname}"
    @tslug = "binh-luan-chung-thu-don-#{vilist.tslug}"

    @htags << "vu:#{vilist.viuser_id}" << "Thư đơn truyện"
    self
  end

  def init_from(vicrit : Vicrit)
    @viuser_id = vicrit.viuser_id

    @olink = @rlink = vicrit.canonical_path

    uname = Viuser.get_uname(vicrit.viuser_id)
    bname = Wninfo.get_btitle_vi(vicrit.nvinfo_id)

    @oname = "Đánh giá của [@#{uname}] cho bộ truyện [#{bname}]"
    @title = "Phản hồi đánh giá ##{vicrit.id} của [@#{uname}]"
    @tslug = "phan-hoi-danh-gia-#{vicrit.id}"

    @htags = ["vu:#{vicrit.viuser_id}", "wn:#{vicrit.nvinfo_id}", "Đánh giá truyện"]

    self
  end

  def init_from(wninfo : Wninfo)
    @viuser_id = 1

    @olink = "/wn/#{wninfo.id}-#{wninfo.bslug}"
    @rlink = "#{@olink}/gd/bants"

    @oname = wninfo.btitle_vi
    @title = "Bình luận chung truyện [#{@oname}]"
    @tslug = "binh-luan-chung-truyen-#{wninfo.bslug}"

    # @intro = TextUtil.truncate(wninfo.bintro, 100)

    @htags << "wn:#{wninfo.id}" << "Bình luận truyện"

    self
  end

  def init_from(viuser : Viuser)
    @viuser_id = viuser.id

    @oname = viuser.uname
    @rlink = @olink = "/@#{@oname}"

    @title = "Trang cá nhân của [@#{@oname}]"
    @tslug = "trang-ca-nhan-cua-#{@oname}"

    @htags << "vu:#{viuser.id}" << "Trang cá nhân"

    self
  end

  def init_as_wnseed_thread
    wn_id, sname = @ukey.split(':', 2)
    wninfo = Wninfo.load!(wn_id.to_i)

    @viuser_id = Viuser.get_id(sname[1..]) if sname.starts_with?('@')

    @oname = "Danh sách chương [#{sname}] truyện [#{wninfo.btitle_vi}]"
    @olink = "#{wninfo.canonical_path}/ch/#{sname}"

    @title = "Bình luận danh sách chương [#{sname}] truyện [#{wninfo.btitle_vi}]"
    @tslug = "binh-luan-danh-sach-chuong-#{sname}-truyen-#{wninfo.bslug}"

    @htags << "wn:#{wn_id}" << "ns:#{sname}" << "Bình luận danh sách chương"

    self
  end

  def init_as_wnchap_thread
    wn_id, ch_no, sname = @ukey.split(':', 3)
    wninfo = Wninfo.load!(wn_id.to_i)

    @viuser_id = Viuser.get_id(sname[1..]) if sname.starts_with?('@')

    @oname = "Chương ##{ch_no} nguồn [#{sname}] truyện [#{wninfo.btitle_vi}]"
    @olink = "#{wninfo.canonical_path}/ch/#{sname}/#{ch_no}"

    @title = "Bình luận chương ##{ch_no} nguồn [#{sname}] truyện [#{wninfo.btitle_vi}]"
    @tslug = "binh-luan-chuong-#{ch_no}-nguon-#{sname}-truyen-#{wninfo.bslug}"

    @htags = ["wn:#{wn_id}", "ns:#{sname}", "ch:#{ch_no}", "Bình luận chương"]

    self
  end

  def update_orig!(db = @@db) : Nil
    db.exec <<-SQL, @id, @olink, @oname, @rlink, @title, @tslug, @htags, @viuser_id
      update #{@@table} set
        olink = $2, oname = $3,
        rlink = $4, title = $5,
        tslug = $6, htags = $7,
        viuser_id = $8
      where id = $1
      SQL
  end

  def thread_type
    case Gdroot::Kind.new(@kind)
    in .global? then "thảo luận chung"
    in .dtopic? then "chủ đề thảo luận"
      ##
    in .author? then "trang tác giả"
    in .wninfo? then "bình luận truyện"
    in .wnseed? then "bình luận nguồn"
    in .wnchap? then "bình luận chương"
      ##
    in .vilist? then "thư đơn truyện"
    in .vicrit? then "đánh giá truyện"
    in .viuser? then "trang người dùng"
      ##
    in .yslist? then "thư đơn yousuu"
    in .yscrit? then "đánh giá yousuu"
    in .ysuser? then "người dùng yousuu"
      ##
    end
  end

  def origin_type
    case Gdroot::Kind.new(@kind)
    in .global? then "thảo luận chung"
    in .dtopic? then "chủ đề thảo luận"
      ##
    in .author? then "trang tác giả"
    in .wninfo? then "bộ truyện"
    in .wnseed? then "danh sách chương"
    in .wnchap? then "chương truyện"
      ##
    in .vilist? then "thư đơn"
    in .vicrit? then "đánh giá"
    in .viuser? then "trang cá nhân"
      ##
    in .yslist? then "thư đơn yousuu"
    in .yscrit? then "đánh giá yousuu"
    in .ysuser? then "người dùng yousuu"
      ##
    end
  end

  def thread_link
    @rlink.empty? ? "/gd/d#{@id}-#{@tslug}" : @rlink
  end

  def origin_link
    @olink.empty? ? self.thread_link : @olink
  end

  def gdrepl_link(gdrepl_id : Int32)
    "#{self.thread_link}#r#{gdrepl_id}"
  end

  def rkey
    case Kind.new(@kind)
    in .global? then "xx:#{@ukey}"
    in .dtopic? then "dt:#{@ukey}"
    in .author? then "au:#{@ukey}"
    in .wninfo? then "wn:#{@ukey}"
    in .wnseed? then "ns:#{@ukey}"
    in .wnchap? then "ch:#{@ukey}"
    in .vicrit? then "vc:#{@ukey}"
    in .vilist? then "vl:#{@ukey}"
    in .viuser? then "vu:#{@ukey}"
    in .yscrit? then "yc:#{@ukey}"
    in .yslist? then "yl:#{@ukey}"
    in .ysuser? then "yu:#{@ukey}"
    end
  end

  ####

  def self.find!(id : Int32)
    @@db.query_one <<-SQL, id, as: self
      select * from #{@@schema.table}
      where id = $1 limit 1
      SQL
  end

  def self.find(kind : Kind, ukey : String)
    @@db.query_one? <<-SQL, kind.value, ukey, as: self
      select * from #{@@schema.table}
      where kind = $1 and ukey = $2 limit 1
      SQL
  end

  def self.find!(kind : Kind, ukey : String)
    find(kind, ukey) || raise "Thread không tồn tại!"
  end

  def self.bump_on_new_reply!(id : Int32, last_repl_at : Time = Time.utc)
    stmt = <<-SQL
      update #{@@schema.table}
      set repl_count = repl_count + 1, last_repl_at = $1
      where id = $2
      returning kind, ukey
      SQL

    kind, ukey = @@db.query_one stmt, last_repl_at, id, as: {Int16, String}

    case Kind.new(kind)
    when .vicrit? then Vicrit.inc_repl_count!(ukey.to_i)
    when .dtopic? then Dtopic.inc_repl_count!(ukey.to_i)
    end
  end

  def self.load!(ruid : String)
    kind, ukey = ruid.split(':', 2)
    return find!(ukey.to_i) if kind == "id"

    kind = Kind.parse_ruid(kind)
    find(kind, ukey) || init(kind, ukey).upsert!
  end

  def self.init(kind : Kind, ukey : String) : self
    gdroot = self.new(kind, ukey)

    case kind
    when .dtopic? then gdroot.init_from(Dtopic.find!(ukey.to_i))
    when .wninfo? then gdroot.init_from(Wninfo.load!(ukey.to_i))
    when .vicrit? then gdroot.init_from(Vicrit.load!(ukey.to_i))
    when .vilist? then gdroot.init_from(Vilist.load!(ukey.to_i))
    when .viuser? then gdroot.init_from(Viuser.load!(ukey))
    when .wnseed? then gdroot.init_as_wnseed_thread
    when .wnchap? then gdroot.init_as_wnchap_thread
    else               gdroot
    end
  end

  def self.glob(ids : Enumerable(Int32))
    @@db.query_all <<-SQL, ids, as: self
      select * from #{@@table} where id = any($1)
      SQL
  end
end
