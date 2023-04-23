require "crorm"
require "../_data"
require "./dtopic"
require "./rpnode"

class CV::Rproot
  enum Kind : Int16
    Dtopic = 0
    Wninfo = 1
    Wnseed = 2
    Wnchap = 3

    Viuser = 20
    Vilist = 21
    Vicrit = 22

    Ysuser = 120
    Yslist = 121
    Yscrit = 122

    Author = 200

    def to_vstr
      case self
      in .dtopic? then "chủ đề"
      in .wninfo? then "bình luận truyện"
      in .wnseed? then "bình luận nguồn"
      in .wnchap? then "bình luận chương"
      in .vilist? then "thư đơn"
      in .vicrit? then "đánh giá truyện"
      in .viuser? then "trang người dùng"
      in .author? then "trang tác giả"
      end
    end
  end

  include Crorm::Model
  include DB::Serializable::NonStrict

  class_getter table = "rproots"
  class_getter db : DB::Database = PGDB

  field id : Int32 = 0, primary: true

  field kind : Int16 = 0_i16
  field pkey : String = ""

  field urn : String = ""

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
    @urn = "gd:#{dtopic.id}"

    @viuser_id = dtopic.viuser_id
    @dboard_id = dtopic.nvinfo_id

    @kind = Kind::Dtopic.value
    @pkey = "#{dtopic.id}"

    @_type = "chủ đề"
    @_link = "/gd/t-#{dtopic.id}-#{dtopic.tslug}"
    @_name = dtopic.title
    @_desc = dtopic.brief

    @repl_count = 0
    @last_seen_at = @last_repl_at = dtopic.updated_at

    @created_at = dtopic.created_at
    @updated_at = dtopic.updated_at
  end

  def initialize(wninfo : Wninfo)
    @urn = "wn:#{wninfo.id}"

    @viuser_id = 1
    @dboard_id = wninfo.id

    @kind = Kind::Wninfo.value
    @pkey = "#{wninfo.id}"

    @_type = "bình luận truyện"
    @_link = "/wn/#{wninfo.id}-#{wninfo.bslug}/bants"

    @_name = wninfo.vname
    @_desc = TextUtil.truncate(wninfo.bintro, 100)

    @repl_count = 0

    @created_at = wninfo.created_at
    @updated_at = wninfo.updated_at
  end

  def initialize(vicrit : Vicrit)
    @urn = "vc:#{vicrit.id}"

    @viuser_id = vicrit.viuser_id
    @dboard_id = vicrit.nvinfo_id

    @kind = Kind::Vicrit.value
    @pkey = "#{vicrit.id}"

    @_type = "đánh giá truyện"
    @_link = "/uc/v#{vicrit.id}"

    @_name = "Đánh giá của [@#{Viuser.get_uname(vicrit.viuser_id)}] cho bộ truyện [#{Wninfo.get_vname(vicrit.nvinfo_id)}]"
    @_desc = TextUtil.truncate(vicrit.itext, 100)

    @repl_count = 0
    @created_at = vicrit.created_at
    @updated_at = vicrit.updated_at
  end

  def initialize(vilist : Vilist)
    @urn = "vl:#{vilist.id}"

    @viuser_id = vilist.viuser_id
    @dboard_id = 0

    @kind = Kind::Vilist.value
    @pkey = "#{vilist.id}"

    @_type = "thư đơn"
    @_link = "/ul/v#{vilist.id}-#{vilist.tslug}"

    @_name = vilist.title
    @_desc = TextUtil.truncate(vilist.dtext, 100)

    @repl_count = 0
    @created_at = vilist.created_at
    @updated_at = vilist.updated_at
  end

  def initialize(wn_id : Int32, ch_no : Int32, sname : String)
    @urn = "ch:#{wn_id}:#{ch_no}:#{sname}"

    @viuser_id = 1
    @dboard_id = wn_id

    @kind = Kind::Wnchap.value
    @pkey = "#{wn_id}:#{ch_no}:#{sname}"

    @_type = "bình luận chương"
    @_link = "/ul/v#{vilist.id}-#{vilist.tslug}"

    @_name = vilist.title
    @_desc = TextUtil.truncate(vilist.dtext, 100)
  end

  # def gen_link
  #   case Kind.new(@kind)
  #   in .dtopic? then "/gd/t-#{@pkey}-#{@slug}"
  #   in .wninfo? then "/wn/#{@pkey}-#{@slug}/bants"
  #   in .wnseed? then "/wn/#{@pkey}-#{@slug}/bants/"
  #   in .wnchap? then "bình luận chương"
  #   in .vilist? then "thư đơn"
  #   in .vicrit? then "đánh giá truyện"
  #   in .viuser? then "/@#{@uslug}"
  #   in .author? then "/wn/=#{@slug}"
  #   end
  # end

  def fix_data
    repls = Rpnode.get_all(rproot: id)
    @repl_count = repls.size
    @last_repl_at = Time.unix(repls.max_of(&.utime))
  end

  def upsert!(db = @@db)
    insert_fields = %w{
      urn viuser_id dboard_id
      _type _name _link _desc
      repl_count last_seen_at last_repl_at
      created_at updated_at}

    update_fields = insert_fields.reject(&.in?(%w(id urn created_at)))

    upsert_stmt = String.build do |sql|
      sql << "insert into " << @@table << '('
      insert_fields.join(sql, ", ")
      sql << ") values ("
      (1..insert_fields.size).join(sql, ", ") { |i, _| sql << '$' << i }
      sql << ") on conflict(urn) do update set "
      update_fields.join(sql, ", ") { |field, _| sql << field << " = excluded." << field }
      sql << " returning *"
    end

    db.query_one upsert_stmt,
      @urn, @viuser_id, @dboard_id,
      @_type, @_name, @_link, @_desc,
      @repl_count, @last_seen_at, @last_repl_at,
      @created_at, @updated_at,
      as: Rproot
  end

  ####

  def self.find!(id : Int32)
    @@db.query_one <<-SQL, id, as: Rproot
      select * from #{@@table}
      where id = $1 limit 1
      SQL
  end

  def self.find(urn : String)
    @@db.query_one? <<-SQL, urn, as: Rproot
      select * from #{@@table}
      where urn = $1 limit 1
      SQL
  end

  def self.find!(urn : String)
    find!(urn) || raise "Thread không tồn tại!"
  end

  def self.bump_on_new_reply!(id : Int32, last_repl_at : Time = Time.utc)
    # FIXME: update parent object

    @@db.exec <<-SQL, last_repl_at, id
      update #{@@table} set repl_count = repl_count + 1, last_repl_at = $1
      where id = $2
      SQL
  end

  def self.init!(urn : String)
    find(urn) || begin
      Log.info { urn.colorize.red }
      type, o_id = urn.split(':')

      case type
      when "id" then find!(o_id.to_i)
      when "gd" then new(Dtopic.find!(o_id.to_i)).upsert!
      when "wn" then new(Wninfo.load!(o_id.to_i)).upsert!
      when "vc" then new(Vicrit.load!(o_id.to_i)).upsert!
      when "vl" then new(Vilist.load!(o_id.to_i)).upsert!
      else           raise "unsuported urn: #{urn}"
      end
    end
  end

  def self.glob(ids : Enumerable(Int32))
    @@db.query_all <<-SQL, ids, as: self
      select * from #{@@table}
      where id = any($1)
      SQL
  end
end
