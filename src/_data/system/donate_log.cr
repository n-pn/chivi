# require "json"
# require "sqlite3"

# class CV::DonateLog
#   include DB::Serializable
#   include JSON::Serializable

#   def self.db_path
#     "var/users/donate_log.db"
#   end

#   def self.init_db
#     open_db do |db|
#       db.exec <<-SQL
#         create table if not exists dlogs(
#           id integer primary key,
#           viuser integer default 0,

#           amount integer default 0,
#           medium varchar default '',

#           ctime integer default 0,
#           _flag integer default 0
#           )
#         SQL

#       db.exec "create index if not exits viuser_idx on dlogs(viuser)"
#       db.exec "create index if not exits medium_idx on dlogs(medium)"
#     end
#   end

#   def self.open_db
#     DB.open("sqlite3:#{db_path}") { |db| yield db }
#   end

#   init_db unless File.exists?(db_path)

#   ###

#   getter sender : Int32
#   getter sendee : Int32

#   getter amount : Int32 = 0
#   getter reason : String = ""

#   getter ctime : Int64

#   def initialize(@sender, @sendee, @amount, @reason, @ctime = Time.utc.to_unix)
#   end

#   def create!
#     fields = [] of String
#     values = [] of DB::Any

#     {% for ivar in @type.instance_vars %}
#       field = {{ivar.name.stringify}}
#       value = @{{ivar.name.id}}

#       fields << field
#       values << value
#     {% end %}

#     self.class.open_db do |db|
#       holder = Array.new(values.size, "?").join(", ")
#       db.exec("insert into xlogs(#{fields.join(", ")}) values (#{holder})", args: values)
#     end
#   end
# end
