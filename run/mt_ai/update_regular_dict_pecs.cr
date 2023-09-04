require "../../src/mt_ai/data/mt_defn"
require "../../src/_util/char_util"
require "../../src/_util/viet_util"

inputs = MT::MtDefn.db("regular").open_ro do |db|
  query = "select zstr, pecs, vstr from defns where cpos = 'NN' and pecs not like '%Ndes%' "
  db.query_all query, as: {String, String, String}
end

# LOCAT_RE = /[^上下内外前后中里间底顶处头左右末边後东西南北][上下内外前后中里间底顶处左右末边後东西南北]$/

# File.open("var/mtdic/mt_ai/.fix/space-raw.tsv", "w") do |file|
#   inputs.compact_map do |zstr, pecs, vstr|
#     next unless zstr.matches?(LOCAT_RE)
#     file << zstr << '\t' << "NN" << '\t' << vstr << '\t'
#     file << pecs << ' ' unless pecs.empty?
#     file << "Ndes" << '\n'
#   end
# end

def import_gold_data
  files = Dir.glob("var/mtdic/mt_ai/gold/*.tsv")

  files.each do |file|
    input = File.read_lines(file).compact_map do |line|
      cols = line.split('\t')
      cols if cols.size > 2
    end

    puts "file: #{file}, size: #{input.size}"

    MT::MtDefn.db("regular").open_tx do |db|
      query = <<-SQL
        insert into defns(zstr, cpos, vstr, pecs, ipecs, _lock)
        values ($1, $2, $3, $4, $5, 2)
        on conflict(zstr, cpos) do update set vstr = $3, pecs = $4, ipecs = $5
      SQL

      input.each do |cols|
        # pp cols
        zstr, cpos, vstr = cols
        pecs = cols[3]? || ""

        zstr = CharUtil.to_canon(zstr, true)
        vstr = vstr.empty? ? "" : VietUtil.fix_tones(vstr)
        ipecs = pecs.empty? ? 0 : MT::MtPecs.parse_list(pecs).to_i
        db.exec query, zstr, cpos, vstr, pecs, ipecs
      end
    end
  end
end

import_gold_data
