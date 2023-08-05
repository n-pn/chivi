# require "sqlite3"
# require "crorm/model"

# class M1::DbTerm
#   @[AlwaysInline]
#   def self.db_path(name : String)
#     "var/mtapp/v1dic/#{name}_v1.dic"
#   end

#   def self.init_sql
#     {{ read_file("#{__DIR__}/sql/terms_v1.sql") }}
#   end

#   def self.db
#     raise "invalid!"
#   end

#   def self.db(name : String)
#     open_db(db_path(name))
#   end

#   ###

#   include Crorm::Model
#   schema "terms", strict: false

#   field id : Int32, pkey: true
#   field dic : Int32 = 0

#   field key : String = ""
#   field val : String = ""

#   field etag : Int32 = 0
#   field epos : Int64 = 0_u64

#   field cost : Int32 = 0
# end
