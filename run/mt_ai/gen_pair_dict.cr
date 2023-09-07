require "../../src/mt_ai/data/vi_term"

MT::ViTerm.db("_old/-29").open_ro do |db|
  file = File.open("var/mtdic/mt_ai/core/vrd_pair.tsv", "a")
  db.query_each "select zstr, vstr, attr from terms" do |rs|
    zstr, vstr, attr = rs.read(String, String, String)
    file.puts "#{zstr}\t_\t#{vstr}\t#{attr}"
  end

  file.close
end
