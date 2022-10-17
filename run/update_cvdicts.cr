require "sqlite3"
require "colorize"

DIC = DB.open "sqlite3://./var/dicts/cvdicts.db"
at_exit { DIC.close }

def fix_ptag(file : String, ptag : String)
  puts file.colorize.cyan

  keys = File.read_lines(file).compact_map do |line|
    next if line.blank? || line[0] == '#'
    "'#{line.split('\t', 2).first}'"
  end

  DIC.exec <<-SQL
    update terms set ptag = '#{ptag}' where key in (#{keys.join(", ")})
  SQL
end

PTAG_DIR = "var/cvmtl/inits"

def fix_ptags
  fix_ptag("#{PTAG_DIR}/map_vabn.tsv", "v!")
  fix_ptag("#{PTAG_DIR}/map_aabn.tsv", "a!")

  fix_ptag("#{PTAG_DIR}/map_verb.tsv", "v")
  fix_ptag("#{PTAG_DIR}/map_vint.tsv", "vi")

  fix_ptag("#{PTAG_DIR}/map_pronoun.tsv", "r")

  fix_ptag("#{PTAG_DIR}/map_advb.tsv", "d")
  fix_ptag("#{PTAG_DIR}/map_conj.tsv", "d")

  fix_ptag("#{PTAG_DIR}/map_place.tsv", "s")
  fix_ptag("#{PTAG_DIR}/map_quanti.tsv", "r")
  fix_ptag("#{PTAG_DIR}/map_sound.tsv", "r")

  fix_ptag("#{PTAG_DIR}/map_suff.tsv", "r")

  fix_ptag("#{PTAG_DIR}/map_uniq.tsv", "r")
end

def import_fixed(file : String, dict_id = 1)
  puts file.colorize.blue

  entries = File.read_lines(file).compact_map do |line|
    next if line.blank? || line[0] == '#'
    key, val, alt_val, ptag = line.split('\t')
    {key, val, alt_val.empty? ? nil : alt_val, ptag}
  end

  DIC.exec "begin transaction"
  entries.each do |key, val, alt, tag|
    select_query = <<-SQL
      select id from terms where dict_id = ? and key = ?
      order by mtime desc limit 1
    SQL

    if term_id = DIC.query_one?(select_query, args: [dict_id, key], as: Int32)
      DIC.exec <<-SQL, args: [val, alt, tag, term_id]
        update terms set val = ?, alt_val = ?, ptag = ? where id = ?
      SQL
    else
      DIC.exec <<-SQL, args: [dict_id, key, val, alt, tag]
        insert into terms (dict_id, key, val, alt_val, ptag) values(?, ?, ?, ?, ?)
      SQL
    end
  end

  DIC.exec "commit"
end

FIX_DIR = "var/cvmtl/fixed"

def import_fixeds
  import_fixed("#{FIX_DIR}/poly_noad.tsv")
end

import_fixeds

# cvmtl_ids = DIC.query_all <<-SQL, as: Int32
#   select id from dicts where dtype = 30
# SQL

# puts cvmtl_ids

# cvmtl_ids.each do |id|
#   clean_dict(id)
# end

# struct Term
#   include DB::Serializable
#   property id : Int32
#   property key : String
#   property val : String
#   property mtime : Int64
# end

# def clean_dict(id)
#   terms = DIC.query_all <<-SQL, as: Term
#     select id, key, val, mtime from terms where dict_id = #{id}
#   SQL

#   terms.group_by(&.key).each do |_key, group|
#     next if group.size < 2
#     group.sort_by!(&.mtime)
#     puts group.size
#     puts "keep: #{group.pop}"

#     fields = group.map(&.id.as(DB::Any))
#     holder = fields.map { "?" }.join(", ")
#     DIC.exec "delete from terms where id in (#{holder})", args: fields
#   end
# end

# def add_alt_val(dict_id, raw_dic_tags)
#   mapping = {} of String => String

#   query = "select key, val from terms where dict_id = #{dict_id}"
#   DIC.query(query) do |rs|
#     rs.each { mapping[rs.read(String)] = rs.read(String) }
#   end

#   mapping.each do |key, val|
#     DIC.exec "begin transaction"

#     DIC.exec <<-SQL, args: [val, key]
#       update terms set alt_val = ? where key = ?
#       and ptag in (#{raw_dic_tags})
#     SQL

#     DIC.exec "commit"
#   end
# end

# add_alt_val(4, "'~an', '~vn'")
# add_alt_val(11, "'~ad', '~vd'")
