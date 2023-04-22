require "crorm"
require "../_data"
require "./dtopic"
require "./rpnode"

class CV::Rproot
  include Crorm::Model

  class_getter table = "muheads"
  class_getter db : DB::Database = PGDB

  field id : Int32 = 0, primary: true
  field urn : String = ""

  field viuser_id : Int32 = 0
  field dboard_id : Int32 = 0

  field _type : String = ""
  field _name : String = ""
  field _desc : String = ""
  field _link : String = ""

  field repl_count : Int32 = 0

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

    @_type = "thư đơn"
    @_link = "/ul/v#{vilist.id}-#{vilist.tslug}"

    @_name = vilist.title
    @_desc = TextUtil.truncate(vilist.dtext, 100)

    @repl_count = 0
    @created_at = vilist.created_at
    @updated_at = vilist.updated_at
  end

  def fix_data
    repls = Rpnode.get_all(muhead_id: id)
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

  def self.find!(urn : String)
    @@db.query_one <<-SQL, urn, as: Rproot
      select * from #{@@table}
      where urn = $1 limit 1
      SQL
  end

  def self.bump!(id : Int32, last_repl_at : Time = Time.utc)
    @@db.exec <<-SQL, last_repl_at, id
      update #{@@table} set repl_count = repl_count + 1, last_repl_at = $1
      where id = $2
      SQL
  end

  def self.init!(urn : String)
    type, o_id, *rest = urn.split(':')

    case type
    when "id" then find!(o_id.to_i)
    when "gd" then new(Dtopic.find!(o_id.to_i)).upsert!
    when "wn" then new(Wninfo.load!(o_id.to_i)).upsert!
    when "vc" then new(Vicrit.load!(o_id.to_i)).upsert!
    when "vl" then new(Vilist.load!(o_id.to_i)).upsert!
    else           raise "unsuported urn: #{urn}"
    end
  end

  def self.glob(ids : Enumerable(Int32))
    @@db.query_all <<-SQL, ids, as: self
      select * from #{@@table}
      where id = any($1)
      SQL
  end
end
