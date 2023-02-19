# require "./_share"

# class YS::YsCrit
#   include DB::Serializable
#   include JSON::Serializable

#   property id : Int32 = 0

#   @[DB::Field(converter: UUIDBlob)]
#   property uuid : UUID

#   property cvbook_id : Int32 = 0
#   property ysbook_id : Int32 = 0

#   property ysuser_id : Int32 = 0
#   property yslist_id : Int32 = 0

#   property stars : Int32 = 0
#   property _sort : Int32 = 0

#   property ztags : String = ""
#   property vtags : String = ""

#   property like_total : Int32 = 0 # last refresh (crawl) time

#   property repl_count : Int32 = 0 # last refresh (crawl) time
#   property repl_total : Int32 = 0 # last refresh (crawl) time

#   property btime : Int64 = 0
#   property mtime : Int64 = 0
#   property rtime : Int64 = 0 # last refresh (crawl) time

#   ####

#   def self.db_path
#     "var/ysapp/yscrits.db"
#   end

#   def self.open_db(path = self.db_path)
#     DB.open("sqlite://#{path}") do |db|
#       yield db
#     end
#   end

#   def self.open_db_tx(path = self.db_path)
#     open_db(path) do |db|
#       db.exec "begin transaction"
#       yield db
#       db.exec "commit"
#     end
#   end

#   def self.init_db(path = self.db_path, reset = false)
#     open_db(path) do |db|
#       db.exec "drop table if exists crits" if reset
#       db.exec <<-SQL
#         create table crits(
#           id integer primary key,
#           uuid blob not null unique,
#           cvbook_id integer not null default 0,
#           ysbook_id integer not null default 0,
#           ysuser_id integer not null default 0,
#           yslist_id integer not null default 0,

#           stars integer not null default 3,
#           _sort integer not null default 0,

#         )
#       SQL
#     end
#   end
# end
