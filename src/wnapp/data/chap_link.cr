# require "sqlite3"
# require "crorm"

# class WN::ChapLink
#   @[AlwaysInline]
#   def self.db_path(db_name : String)
#     "var/chaps/infos/#{db_name}-links.db"
#   end

#   def self.init_sql
#     <<-SQL
#     create table if not exists #{@@table} (
#       fg_ch_no integer not null,
#       --
#       bg_sname varchar not null,
#       bg_s_bid integer not null,
#       --
#       bg_ch_no integer not null,
#       bg_s_cid integer not null,
#       --
#       _flag integer not null default 0,
#       primary key (fg_ch_no, bg_sname)
#     );
#     SQL
#   end

#   ###

#   include Crorm::Model
#   schema "links"

#   field fg_ch_no : Int32, pkey: true

#   field bg_sname : String
#   field bg_s_bid : Int32

#   field bg_ch_no : Int32
#   field bg_s_cid : Int32

#   field _flag : Int32 = 0
# end
