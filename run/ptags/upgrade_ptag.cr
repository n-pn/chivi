require "option_parser"

require "../../src/mt_v2/cv_data/*"

def fix_dict(type : String)
  M2::CvTerm.open_db_tx(type) do |db|
    ptags = db.query_all "select distinct(ptag) from terms", as: String

    ptags.each do |old_ptag|
      new_ptag = REMAP[old_ptag]
      puts "#{old_ptag} => #{new_ptag}"
      db.exec "update terms set ptag = ? where ptag = ?", args: [new_ptag, old_ptag]
    end
  end
end

record Term, id : Int32, key : String, val : String do
  include DB::Serializable
end

def fix_tags(type : String, ptag : String, persist = false)
  color = persist ? :yellow : :blue

  M2::CvTerm.open_db_tx(type) do |db|
    query = "select id, key, val from terms where ptag = ?"
    terms = db.query_all query, args: [ptag], as: Term

    update_query = "update terms set ptag = ? where id = ?"

    terms.each do |term|
      new_ptag = M2::PosTag.map_str(ptag, term.key, term.val)
      puts "[#{term.key}  #{term.val}] #{ptag} => #{new_ptag}".colorize(color)

      next unless persist
      db.exec update_query, args: [new_ptag, term.id]
    end
  end
end

persist = false
ptags = [] of String

OptionParser.parse(ARGV) do |parser|
  parser.on("--persist", "persist") { persist = true }
  parser.unknown_args { |x| ptags = x }
end

ptags.each do |ptag|
  fix_tags("core", ptag, persist: persist)
  fix_tags("dict", ptag, persist: persist)
end
