require "../../src/mt_ai/data/ai_term"

MT::AiTerm.db("_old/-29").open_ro do |db|
  file = File.open("var/mtdic/mt_ai/core/vrd_pair.tsv", "a")
  db.query_each "select zstr, vstr, prop from terms" do |rs|
    zstr, vstr, prop = rs.read(String, String, String)
    file.puts "#{zstr}\t_\t#{vstr}\t#{prop}"
  end

  file.close
end
