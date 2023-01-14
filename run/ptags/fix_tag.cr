require "yaml"
require "../../src/mt_v2/cv_data/*"

record Term, id : Int32, key : String, val : String do
  include DB::Serializable
end

def fix_tags(type : String, ptag : String, new_ptag : String, persist = false)
  color = persist ? :yellow : :blue
  puts "#{ptag} => #{new_ptag}"

  MT::CvTerm.open_db_tx(type) do |db|
    query = "select id, key, val from terms where ptag = ?"
    terms = db.query_all query, args: [ptag], as: Term

    update_query = "update terms set ptag = ? where id = ?"

    terms.each do |term|
      Log.info { "[#{term.key}  #{term.val}]".colorize(color) }
      next unless persist
      db.exec update_query, args: [new_ptag, term.id]
    end
  end
end

def remap(name : String, persist = false)
  map = load_fix(name)

  map.each do |ptag, new_ptag|
    fix_tags("core", ptag, new_ptag, persist: persist)
    fix_tags("book", ptag, new_ptag, persist: persist)
  end
end

def load_fix(name : String)
  File.open("run/ptag/fix_tag/#{name}.yml", "r") do |file|
    Hash(String, String).from_yaml(file)
  end
end

persist = ARGV.includes?("--save")

ARGV.each do |argv|
  next if argv.starts_with? '-'
  remap(argv, persist: persist)
end
