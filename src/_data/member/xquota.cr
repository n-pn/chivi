# require "../_data"

# class Xquota
#   class_getter init_sql = <<-SQL
#     create table xquota(
#       uname text not null default '',
#       vu_ip text not null default '',
#       mtime integer not null,
#       --
#       wcount integer not null default 0,
#       charge integer not null default 0,
#       --
#       xtype text not null default '',
#       xorig text not null default ''
#     ) strict;

#   SQL

#   DIR = "var/users/xquota"
#   Dir.mkdir_p(DIR)

#   @[AlwaysInline]
#   def self.db_path(date : Time)
#     "#{DIR}/#{date.to_s("%F")}.db3"
#   end

#   include Crorm::Model
#   schema "xquota", :sqlite, multi: true

#   field rowid : Int32, pkey: true, auto: true

#   field uname : String = ""
#   field vu_ip : String = ""
#   field mtime : Int64 = 0

#   field wcount : Int32 = 0
#   field charge : Int32 = 0

#   field xtype : String = ""
#   field xorig : String = ""

#   def initialize(@uname = "", @vu_ip = "",
#                  @mtime = Time.local.to_unix,
#                  @wcount = 0, @charge = "",
#                  @xtype = "", @xorig = "")
#   end
# end
