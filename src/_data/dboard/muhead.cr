require "crorm"
require "../_data"
require "./dtopic"
require "./murepl"

class CV::Muhead
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
  field member_ids : Array(Int32)

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

    @_type = "thảo luận"
    @_link = "/gd/t-#{dtopic.id}-#{dtopic.tslug}"
    @_name = dtopic.title
    @_desc = dtopic.brief

    @repl_count = 0
    @member_ids = [dtopic.viuser_id]
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
    @member_ids = [] of Int32

    @created_at = wninfo.created_at
    @updated_at = wninfo.updated_at
  end

  def fix_data
    murepls = Murepl.get_all(muhead_id: id)
    @repl_count = murepls.size
    @member_ids.concat(murepls.map(&.viuser_id)).uniq!
    @last_repl_at = Time.unix(murepls.max_of(&.utime))
  end

  def upsert!(db = @@db)
    insert_fields = %w{
      urn viuser_id dboard_id
      _type _name _link _desc
      repl_count member_ids
      last_seen_at last_repl_at
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
      @repl_count, @member_ids,
      @last_seen_at, @last_repl_at,
      @created_at, @updated_at,
      as: Muhead
  end

  ####

  def self.find!(id : Int32)
    @@db.query_one <<-SQL, id, as: Muhead
      select * from #{@@table}
      where id = $1 limit 1
      SQL
  end

  def self.find!(urn : String)
    @@db.query_one <<-SQL, urn, as: Muhead
      select * from #{@@table}
      where urn = $1 limit 1
      SQL
  end

  def self.bump!(id : Int32, last_repl_at : Time = Time.utc)
    @@db.exec <<-SQL, id, last_repl_at
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
    else           raise "unsuported urn: #{urn}"
    end
  end
end
