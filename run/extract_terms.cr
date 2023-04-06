require "sqlite3"

INP_DIR = "var/cvmtl/dicts"
OUT_DIR = "src/mtapp/init"

def extract_freq(db_path : String, name = File.basename(db_path, ".db"))
  output = {} of String => Hash(String, Int32)

  out_dir = "#{OUT_DIR}/#{name}"
  Dir.mkdir_p(out_dir)

  DB.open("sqlite3:#{db_path}") do |db|
    stmt = "select ptag, word, freq from freqs order by freq desc"
    db.query_each stmt do |rs|
      hash = output[rs.read(String)] ||= {} of String => Int32
      hash[rs.read(String)] = rs.read(Int32)
    end
  end

  output.each do |ptag, terms|
    puts "#{name}: #{ptag} => #{terms.size}"
    File.open("#{out_dir}/#{ptag}.tsv", "w") do |file|
      terms.each do |word, freq|
        file << word << '\t' << freq << '\n'
      end
    end
  end
end

# extract_freq("#{INP_DIR}/ctbv5-freq.db")
# extract_freq("#{INP_DIR}/ctbv6-freq.db")
# extract_freq("#{INP_DIR}/ctbv8-freq.db")
# extract_freq("#{INP_DIR}/ctbv9-freq.db")

extract_freq("#{INP_DIR}/pku98-freq.db")
extract_freq("#{INP_DIR}/pmtv1-freq.db")
extract_freq("#{INP_DIR}/pku14-freq.db")
