require "sqlite3"

PKU = DB.open("sqlite3:var/cvmtl/dicts/pku98-freq.db")
at_exit { PKU.close }

def extract(ptag : String, out_file : String, mode = "w")
  file = File.open(out_file, mode)

  query = "select word, viet, ptag, freq from freqs where ptag like ?"
  PKU.query_each query, ptag do |rs|
    word, viet, ptag, freq = rs.read(String, String, String, Int32)

    file.puts "#{word}\t#{viet}\t#{ptag}\t\t#{freq}\t"
  end

  file.close
end

def out_path(name : String)
  "var/cvmtl/inits/#{name}.tab"
end

# extract("p", out_path("sealed/preposition"))
# extract("c", out_path("sealed/conjunction"))
# extract("u%", out_path("sealed/particle"))

extract("r%", out_path("pronoun/unknown"))
