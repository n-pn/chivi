require "../../src/_util/char_util"
require "../../src/mt_ai/data/mt_term"

DB_PATH = "var/mtdic/specs.db3"

POSS = {
  "AS",
  "BA",
  "CC",
  "CS",
  "DEC",
  "DEG",
  "DER",
  "DEV",
  "DT",
  "ETC",
  "IJ",
  "LB",
  "LC",
  "M",
  "MSP",
  "ON",
  "P",
  "PN",
  "PU",
  "SB",
  "SP",
  "VC",
  "VE",
}

def essence?(pos : String, tok : String)
  case pos
  when "CD", "OD", "NT", "PU" then tok.size == 1
  when .in?(POSS)             then true
  else                             false
  end
end

inputs = Set({String, String}).new
allows = Set(String).new
counts = Hash(String, Int32).new(0)

DB.connect("sqlite3:#{DB_PATH}?immutable=1") do |db|
  db.query_each "select tok_gold, pos_gold from specs" do |rs|
    toks = rs.read(String).strip.split(' ')
    poss = rs.read(String).strip.split(' ')

    raise "invalid" unless toks.size == poss.size

    toks.zip(poss) do |tok, pos|
      tok = CharUtil.to_canon(tok, false)
      counts[tok] += 1

      inputs << {tok, pos}
      allows << tok if essence?(pos: pos, tok: tok)
    end
  end
end

inputs = inputs.select { |tok, pos| allows.includes?(tok) }
inputs = inputs.to_a.sort_by! { |tok, pos| -counts[tok] }
puts inputs.size

File.open("var/mtdic/essence-2.tsv", "w") do |file|
  inputs.each do |tok, pos|
    file << tok << '\t' << pos << '\n'
  end
end

output = [] of AI::MtTerm

inputs.each do |tok, pos|
  term = AI::MtTerm.new(tok, pos)
  term._flag = -1
  output << term
end

AI::MtTerm.db("essence").open_tx do |db|
  output.each(&.upsert!(db: db))
end
