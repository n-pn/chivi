# require "sqlite3"

# class SP::EntRelate
#   include DB::Serializable
#   property form : String
#   property etag : String
#   property related : String

#   @[AlwaysInline]
#   def self.db_path
#     "var/dicts/defns/ent_relates.db"
#   end

#   def self.upsert(form : String, etag : String, related : String, db = self.db)
#     db.exec(upsert_sql, form, etag, related)
#   end

#   # open database for reading/writing
#   def self.open_db
#     DB.open("sqlite3:#{self.db_path}") { |db| yield db }
#   end

#   class_getter db : DB::Database do
#     db = DB.open("sqlite3:#{self.db_path}")
#     at_exit { db.close }
#     db
#   end

#   # open database with transaction for writing
#   def self.open_tx
#     open_db do |db|
#       db.exec "pragma synchronous = normal"
#       db.exec "begin"
#       yield db
#       db.exec "commit"
#     end
#   end

#   def self.init_db(reset : Bool = false)
#     open_db do |db|
#       db.exec "drop table if exists ent_relates" if reset
#       db.exec "pragma journal_mode = WAL"

#       db.exec <<-SQL
#         create table if not exists ent_relates (
#           form varchar not null,
#           etag varchar not null,
#           related varchar not null default '',
#           --
#           primary key (form, etag)
#         )
#       SQL
#     end
#   end

#   def self.upsert_sql
#     <<-SQL
#       insert into ent_relates (form, etag, related) values (?, ?, ?)
#       on conflict(form, etag) do update set related = excluded.related
#     SQL
#   end
# end

# class SP::EntValue
#   include DB::Serializable
#   property form : String
#   property etag : String
#   property json : String

#   def self.upsert(form : String, etag : String, json : String, db = self.db)
#     db.exec(upsert_sql, form, etag, json)
#   end

#   ###

#   @[AlwaysInline]
#   def self.db_path
#     "var/dicts/defns/ent_values.db"
#   end

#   # open database for reading/writing
#   def self.open_db
#     DB.open("sqlite3:#{self.db_path}") { |db| yield db }
#   end

#   class_getter db : DB::Database do
#     db = DB.open("sqlite3:#{self.db_path}")
#     at_exit { db.close }
#     db
#   end

#   # open database with transaction for writing
#   def self.open_tx
#     open_db do |db|
#       db.exec "pragma synchronous = normal"
#       db.exec "begin"
#       yield db
#       db.exec "commit"
#     end
#   end

#   def self.init_db(reset : Bool = false)
#     open_db do |db|
#       db.exec "drop table if exists ent_values" if reset
#       db.exec "pragma journal_mode = WAL"

#       db.exec <<-SQL
#         create table if not exists ent_values (
#           form varchar not null,
#           etag varchar not null,
#           json varchar not null default '',
#           primary key (form, etag)
#         )
#       SQL
#     end
#   end

#   def self.upsert_sql
#     <<-SQL
#       insert into ent_values (form, etag, json) values (?, ?, ?)
#       on conflict (form, etag) do update set 'json' = excluded.json
#     SQL
#   end
# end

# class SP::EntFreq
#   include DB::Serializable

#   property form : String
#   property etag : String

#   property freq : Int32 = 0

#   def initialize(@form, @etag, @freq = 0)
#   end

#   # def self.find(form : String)
#   #   query = "select * from ent_freqs where form = ?"
#   #   open_db(dict, &.query_one?(query, form, as: self))
#   # end

#   # def self.upsert(form : String, etag : String, extra : String)
#   #   open_tx { |db| db.exec(self.upsert_sql, form, etag, extra, Time.utc.to_unix) }
#   # end

#   # def self.upsert(items : Array(self))
#   #   open_tx do |db|
#   #     sql = upsert_sql
#   #     items.each { |term| db.exec(sql, term.form, term.etag, term.extra, term.mtime) }
#   #   end
#   # end

#   def self.upsert(form : String, etag : String, freq : Int32, db = self.db)
#     db.exec(upsert_sql, form, etag, freq)
#   end

#   def self.upsert_sql
#     <<-SQL
#       insert into ent_freqs (form, etag, freq) values (?, ?, ?)
#       on conflict (form, etag) do update set freq = excluded.freq
#     SQL
#   end

#   # return path for database
#   @[AlwaysInline]
#   def self.db_path
#     "var/dicts/defns/ent_freqs.dic"
#   end

#   class_getter db : DB::Database do
#     db = DB.open("sqlite3:#{self.db_path}")
#     at_exit { db.close }
#     db
#   end

#   # open database for reading/writing
#   def self.open_db
#     DB.open("sqlite3:#{self.db_path}") { |db| yield db }
#   end

#   # open database with transaction for writing
#   def self.open_tx
#     open_db do |db|
#       db.exec "pragma synchronous = normal"
#       db.exec "begin"
#       yield db
#       db.exec "commit"
#     end
#   end

#   def self.init_db(reset : Bool = false)
#     open_db do |db|
#       db.exec "drop table if exists ent_freqs" if reset
#       db.exec "pragma journal_mode = WAL"

#       db.exec <<-SQL
#         create table if not exists ent_freqs (
#           form varchar not null,
#           etag varchar not null,
#           freq integer not null default 0,
#           primary key (form, etag)
#         )
#       SQL

#       db.exec "create index if not exists etag_idx on ent_freqs (etag, freq)"
#     end
#   end
# end
