require "./open_db"

class MT::CvTerm
  include Crorm::Model
  self.table = "terms"

  column id : Int32, primary: true
  column dic : Int32

  column key : String
  column raw : String?

  column val : String
  column alt : String?

  column ptag : String = ""
  column wseg : Int32 = 2

  column user : String = ""
  column time : Int64 = 0_i64
  column flag : Int32 = 0

  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def save!(db : DB::Database, id : Int32?)
    mark_prevs_as_dead!(db)

    fields, values = self.changes(id)
    holder = Array.new(fields.size, "?").join(", ")

    db.exec <<-SQL, args: values
      replace into terms (#{fields.join(", ")}) values (#{holder})
    SQL
  end

  def changes(id : Int32?)
    fields = [] of String
    values = [] of DB::Any

    if id
      fields << "id"
      values << id
    end

    {% for ivar in @type.instance_vars %}
      {% if ivar.name.stringify != "id" %}
        fields << {{ ivar.name.stringify }}
        values << @{{ ivar.name.id }}
      {% end %}
    {% end %}

    {fields, values}
  end

  def mark_prevs_as_dead!(db : DB::Database)
    dic = @dic.not_nil!
    args = [dic, @key.not_nil!]

    query = String.build do |str|
      str << "update terms set flag = 1 where key = ?1 and (dic = ?2"

      if dic > 0 # base dict
        args << -dic
        str << " and flag = 0) or (dic = ?3 and flag = 0)"
      elsif flag == -1 # user dict
        args << @user.not_nil!
        str << " and flag = -1 and user = ?3)"
      else # temp dict
        str << " and flag = 0)"
      end
    end

    db.exec query, args: args
  end

  ###########

  def self.total(type : String, query = "true")
    DbRepo.open_db(type, &.scalar("select count(*) from terms where #{query}"))
  end

  def self.total(type : String, dic : Int32)
    total(type, "dic = #{dic}")
  end

  def self.load_all(type : String, dic : Int32)
    DbRepo.open_db(type) do |db|
      query = <<-SQL
        select * from terms
        where dic = ?
      SQL

      db.query_all(query, args: [dic], as: CvTerm)
    end
  end

  @[AlwaysInline]
  def self.db_path(type : String) : String
    "var/dicts/#{type}.dic"
  end

  def self.open_db(type : String)
    DB.open("sqlite3:./var/dicts/#{type}.dic") { |db| yield db }
  end
end
