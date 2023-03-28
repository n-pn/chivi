require "json"
require "sqlite3"

DIR = "var/texts/anlzs/out"
OUT = "var/cvmtl/vocab/texsmart"

SELECT_STMT = "select zstr, count from terms where ztag = $1"

def extract(ztag : String, out_path = "#{OUT}/#{ztag}.tsv")
  output = Hash(String, Int32).new(0)

  inputs = Dir.glob("#{DIR}/*.db")

  inputs.each_with_index(1) do |db_path, idx|
    puts "[#{ztag}/#{idx}/#{inputs.size}] read: #{db_path}, current: #{output.size} entries"

    DB.open("sqlite3:#{db_path}") do |db|
      db.query_each(SELECT_STMT, ztag) do |rs|
        output[rs.read(String)] += rs.read(Int32)
      end
    end
  end

  output = output.to_a.sort_by!(&.[1].-)

  File.open(out_path, "w") do |file|
    output.join(file, '\n') { |(key, val)| file << key << '\t' << val }
  end

  puts "saved #{output.size} entries to #{out_path}"
end

ARGV.each do |ztag|
  extract(ztag)
end
