require "sqlite3"

DBs = {
  "p98" => DB.open("sqlite3:var/cvmtl/dicts/pku98-freq.db"),
  "p14" => DB.open("sqlite3:var/cvmtl/dicts/pku14-freq.db"),
  "pmt" => DB.open("sqlite3:var/cvmtl/dicts/pmtv1-freq.db"),
}

at_exit { DBs.each_value(&.close) }

def extract(dict : String, ptag : String, path : String, mode = "w")
  file = File.open("var/cvmtl/inits/#{path}.#{dict}.tab", mode)

  query = "select word, viet, ptag, freq from freqs where ptag like ?"
  DBs[dict].query_each query, ptag do |rs|
    word, viet, ptag, freq = rs.read(String, String, String, Int32)

    file.puts "#{word}\t#{viet}\t#{ptag}\t\t#{freq}\t"
  end

  file.close
end

def out_path(name : String, kind : String)
end

# extract("pmt", "p%", "sealed/preposition")
# extract("p98", "p%", "sealed/preposition")
# extract("p14", "p%", "sealed/preposition")

# extract("pmt", "c%", "sealed/conjunction")
# extract("p98", "c%", "sealed/conjunction")
# extract("p14", "c%", "sealed/conjunction")

# extract("pmt", "u%", "sealed/particle")
# extract("p98", "u%", "sealed/particle")
# extract("p14", "u%", "sealed/particle")

# extract("p14", "rr%", "pronoun/personal-pronoun")
# extract("p14", "ry%", "pronoun/interrogative-pronoun")
# extract("p14", "rz%", "pronoun/demonstrative-pronoun")
# extract("p14", "r", "pronoun/indefinite-pronoun")

# extract("p98", "r%", "pronoun/unknown-pronoun")

# extract("pmt", "rr%", "pronoun/personal-pronoun")
# extract("pmt", "ry%", "pronoun/interrogative-pronoun")
# extract("pmt", "rz%", "pronoun/demonstrative-pronoun")
# extract("pmt", "r", "pronoun/indefinite-pronoun")

# extract("p98", "q%", "quantifier/unknown")
# extract("pmt", "q%", "quantifier/unknown")

# extract("p14", "qv%", "quantifier/verb-quanti")
# extract("p14", "qt%", "quantifier/time-quanti")

# extract("p14", "q", "quantifier/noun-quanti")

# extract("pmt", "qv", "quantifier/verb-quanti")
# extract("pmt", "qt", "quantifier/time-quanti")

extract("pmt", "t%", "n-temporal/unknown")
extract("p98", "t%", "n-temporal/unknown")
extract("p14", "t%", "n-temporal/unknown")
