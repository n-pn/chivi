require "sqlite3"
require "colorize"

require "../../src/mt_v2/cv_data/*"

class Dict
  def initialize(@type : String)
  end

  def fix_ptag(file : String, ptag : String)
    puts file.colorize.cyan

    keys = File.read_lines(file).compact_map do |line|
      next if line.blank? || line[0] == '#'
      "'#{line.split('\t', 2).first}'"
    end

    M2::DbRepo.open_db(@type) do |db|
      db.exec <<-SQL
        begin transaction;
        update terms set ptag = '#{ptag}' where key in (#{keys.join(", ")})
        commit;
      SQL
    end
  end

  PTAG_DIR = "var/mt_v2/inits"

  def fix_ptags
    fix_ptag("#{PTAG_DIR}/map_pronoun.tsv", "r")
    fix_ptag("#{PTAG_DIR}/map_quanti.tsv", "m")
    fix_ptag("#{PTAG_DIR}/map_space.tsv", "s")
    # fix_ptag("#{PTAG_DIR}/map_sound.tsv", "y")

    fix_ptag("#{PTAG_DIR}/map_verb.tsv", "v")
    fix_ptag("#{PTAG_DIR}/map_vint.tsv", "vi")

    fix_ptag("#{PTAG_DIR}/map_vabn.tsv", "v!")
    fix_ptag("#{PTAG_DIR}/map_aabn.tsv", "a!")

    fix_ptag("#{PTAG_DIR}/map_advb.tsv", "d")
    fix_ptag("#{PTAG_DIR}/map_conj.tsv", "c")

    fix_ptag("#{PTAG_DIR}/map_suff.tsv", "k")

    # fix_ptag("#{PTAG_DIR}/map_uniq.tsv", "!")

    fix_ptag("#{PTAG_DIR}/not_vcompl.tsv", "~vc")

    fix_ptag("#{PTAG_DIR}/map_qttemp.tsv", "~qt")
    fix_ptag("#{PTAG_DIR}/not_quanti.tsv", "~qt")

    fix_ptag("#{PTAG_DIR}/map_nqtemp.tsv", "~nq")
    fix_ptag("#{PTAG_DIR}/not_nquant.tsv", "~nq")
  end

  def add_fixed(file : String, dic = 1)
    puts file.colorize.blue

    entries = File.read_lines(file).compact_map do |line|
      next if line.blank? || line[0] == '#'
      key, val, alt, ptag = line.split('\t')
      {key, val, alt.empty? ? nil : alt, ptag}
    end

    M2::DbRepo.open_db(@type) do |db|
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

  FIX_DIR = "var/mt_v2/fixed"

  def add_fixes
    # import_fixed("#{FIX_DIR}/poly_noad.tsv")
    add_fixed("#{FIX_DIR}/suffixes.tsv")
    add_fixed("#{FIX_DIR}/fixtures.tsv")
  end

  record Data, id : Int32, val : String do
    include DB::Serializable

    def inspect(io : IO)
      io << val
    end
  end

  def fix_once!
    M2::DbRepo.open_db(@type) do |db|
      query = <<-SQL
        select id, val from terms where ptag = 'Ns';
      SQL

      entries = db.query_all(query, as: Data)
      entries.select! { |x| x.val == x.val.downcase }

      db.exec "begin transaction"
      entries.each do |x|
        db.exec "update terms set ptag = 's' where id = ?", args: [x.id]
      end

      db.exec "commit"
    end
  end
end

# dict = Dict.new("core")
# dict.fix_ptags
# dict.add_fixes

# dict.fix_once!
