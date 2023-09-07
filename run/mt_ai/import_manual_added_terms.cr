require "../../src/mt_ai/data/vi_term"

def import_gold_data
  files = Dir.glob("var/mtdic/mt_ai/gold/*.tsv").sort!

  files.each do |file|
    terms = File.read_lines(file).compact_map do |line|
      cols = line.split('\t')
      MT::ViTerm.new(cols) if cols.size > 2
    end

    puts "file: #{file}, size: #{terms.size}"
    terms.each(&._lock = 2)

    MT::ViTerm.db("regular").open_tx do |db|
      terms.each(&.upsert!(db: db))
    end
  end
end

import_gold_data
