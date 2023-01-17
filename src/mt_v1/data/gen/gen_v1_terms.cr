require "../v1_defn"
require "../v1_term"
require "../../../_util/text_util"

include M1

def update_terms(terms : Array(DbTerm), name : String)
  DbTerm.repo(name).open_tx do |db|
    terms.each do |term|
      fields, values = term.get_changes
      db.upsert("terms", fields, values)
    end
  end
end

def gen_base_terms(name = "main", tab = 1)
  terms = [] of DbTerm

  DbDefn.repo.open_db do |db|
    query = "select * from defns where tab = ? and _flag >= 0 order by id asc"
    db.query_all(query, tab, as: DbDefn).each do |defn|
      terms << defn.to_term
    end
  end

  update_terms(terms, name)
end

def gen_user_terms
  terms = Hash(String, Array(DbTerm)).new { |h, k| h[k] = [] of DbTerm }

  DbDefn.repo.open_db do |db|
    query = "select * from defns where tab = 3 and _flag >= 0 order by id asc"

    db.query_all(query, as: DbDefn).each do |defn|
      terms[defn.uname] << defn.to_term
    end
  end

  terms.each do |uname, array|
    update_terms(array, "@" + uname)
  end
end

gen_base_terms("_main", 1)
gen_base_terms("_temp", 2)

gen_user_terms
