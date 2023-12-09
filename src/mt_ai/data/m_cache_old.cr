# require "crorm"
# require "../../_util/hash_util"
# require "../../_util/char_util"

# require "../_raw/*"

# class MT::MCacheOld
#   DIR = ENV.fetch("MC_DIR", "/2tb/var.chivi/cache/mdata")
#   Dir.mkdir_p(DIR)

#   DB_CACHE = {} of String => Crorm::SQ3

#   # def self.load_db(char : Char, type : String)
#   #   DB_CACHE["#{char}-#{type}"] ||= self.db(char, type)
#   # end

#   def self.load_db(block : Int32, type : String)
#     DB_CACHE["#{block}-#{type}"] ||= self.db(block, type)
#   end

#   # def self.db_path(word : String, type : String)
#   #   "#{DIR}/#{word}.#{type}.db3"
#   # end

#   # def self.db_path(char : Char, type : String)
#   #   "#{DIR}/#{char}.#{type}.db3"
#   # end

#   def self.db_path(block : Int32, type : String)
#     "#{DIR}/#{block}.#{type}.db3"
#   end

#   class_getter init_sql = <<-SQL
#     create table mcache(
#       rid int not null,
#       tok text not null,
#       --
#       con text not null,
#       dep text not null default '',
#       --
#       msra text not null default '',
#       onto text not null default '',
#       --
#       uname text not null default '',
#       mtime int not null default 0,
#       --
#       primary key (rid, tok)
#     ) strict, without rowid;
#     SQL

#   ###

#   include Crorm::Model

#   schema "mcache", :sqlite, multi: true

#   field rid : Int64, pkey: true
#   field tok : String, pkey: true

#   field con : String = "" # constituent tree in bracket format
#   field dep : String = "" # universal dependency parsing

#   # field pos : String = ""
#   # field sdp : String = ""

#   field msra : String = "" # msra
#   field onto : String = "" # ontonotes

#   field uname : String = "" # last modified by
#   field mtime : Int64 = 0   # last modified at

#   def initialize(@rid, @tok,
#                  @con = "", @dep = "",
#                  @msra = "", @onto = "",
#                  @uname = "", @mtime = Time.utc.to_unix)
#   end

#   UPSERT_SQL = @@schema.upsert_stmt(keep_fields: ["con"])

#   def upsert_con!(db)
#     self.upsert!(query: UPSERT_SQL, db: db)
#   end

#   ###

#   def self.gen_rid(tok : Array(String))
#     HashUtil.fnv_1a_64(tok).unsafe_as(Int64)
#   end

#   FIND_BY_STR_SQL = "select * from mcache where rid = $1 order by mtime desc limit 1"

#   @[AlwaysInline]
#   def self.find(inp : String, db : Crorm::DBX)
#     db.query_one? FIND_BY_STR_SQL, self.gen_rid(inp), as: self
#   end

#   @[AlwaysInline]
#   def self.find(inp : String, type : String)
#     self.load_db(inp.size, type).open_ro { |db| find(inp, db: db) }
#   end

#   FIND_BY_TOK_SQL = "select * from mcache where rid = $1 and tok = $2 limit 1"

#   @[AlwaysInline]
#   def self.find(inp : Array(String), db : Crorm::DBX)
#     db.query_one? FIND_BY_TOK_SQL, gen_rid(inp), inp.join('\t'), as: self
#   end

#   @[AlwaysInline]
#   def self.find(inp : Array(String), type : String)
#     self.load_db(inp.sum(&.size), type).open_ro { |db| find(inp, db: db) }
#   end

#   ###

#   def self.find_all(inp : Array(String), type : String)
#     inp.map { |str| find(str, type) }
#   end

#   def self.find_all(inp : Array(Array(String)))
#     inp.map { |str| find(str) }
#   end

#   def self.find_all!(inp : Array(String))
#     indexes = [] of Int32
#     missing = String::Builder.new

#     res = inp.map_with_index do |str, idx|
#       find(str) || begin
#         indexes << idx
#         missing << str << '\n'
#         ""
#       end
#     end
#   end
# end
