require "sqlite3"
require "colorize"

require "../src/cvmtl/cv_data/*"

class Dict
  def initialize(@type : String)
  end

  def fix_ptag(file : String, ptag : String)
    puts file.colorize.cyan

    keys = File.read_lines(file).compact_map do |line|
      next if line.blank? || line[0] == '#'
      "'#{line.split('\t', 2).first}'"
    end

    MT::DbRepo.open_db(type) do |db|
      db.exec <<-SQL
        begin transaction;
        update terms set ptag = '#{ptag}' where key in (#{keys.join(", ")})
        commit;
      SQL
    end
  end
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

def import_fixed(file : String, dic = 1)
  puts file.colorize.blue

  entries = File.read_lines(file).compact_map do |line|
    next if line.blank? || line[0] == '#'
    key, val, alt, ptag = line.split('\t')
    {key, val, alt.empty? ? nil : alt, ptag}
  end

  MT::DbRepo.open_db("core") do |db|
    db.exec "begin transaction"

    entries.each do |key, val, alt, tag|
      select_query = <<-SQL
        select id from terms where dic = ? and key = ?
        order by time desc limit 1
      SQL

      if id = db.query_one?(select_query, args: [dic, key], as: Int32)
        db.exec <<-SQL, args: [val, alt, tag, id]
          update terms set val = ?, alt = ?, ptag = ? where id = ?
        SQL
      else
        db.exec <<-SQL, args: [dic, key, val, alt, tag]
          insert into terms (dic, key, val, alt, ptag) values(?, ?, ?, ?, ?)
        SQL
      end
    end

    db.exec "commit"
  end
end

FIX_DIR = "var/cvmtl/fixed"

def import_fixeds
  import_fixed("#{FIX_DIR}/poly_noad.tsv")
  import_fixed("#{FIX_DIR}/uniqword.tsv")
  import_fixed("#{FIX_DIR}/suffixes.tsv")
  import_fixed("#{FIX_DIR}/fixtures.tsv")
end

import_fixeds
