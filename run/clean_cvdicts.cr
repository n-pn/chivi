require "sqlite3"
require "colorize"
require "../src/mtlv1/vp_dict/vp_term"

INP = "var/dicts"
DIC = DB.open "sqlite3://./#{INP}/cvdicts.db"
at_exit { DIC.close }

cvmtl_ids = DIC.query_all <<-SQL, as: Int32
  select id from dicts where dtype = 30
SQL

puts cvmtl_ids

cvmtl_ids.each do |id|
  clean_dict(id)
end

struct Term
  include DB::Serializable
  property id : Int32
  property key : String
  property val : String
  property mtime : Int64
end

def clean_dict(id)
  terms = DIC.query_all <<-SQL, as: Term
    select id, key, val, mtime from terms where dict_id = #{id}
  SQL

  terms.group_by(&.key).each do |_key, group|
    next if group.size < 2
    group.sort_by!(&.mtime)
    puts group.size
    puts "keep: #{group.pop}"

    fields = group.map(&.id.as(DB::Any))
    holder = fields.map { "?" }.join(", ")
    DIC.exec "delete from terms where id in (#{holder})", args: fields
  end
end
