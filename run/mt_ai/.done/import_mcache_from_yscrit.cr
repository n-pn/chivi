require "../../src/mt_ai/data/m_cache"

def import_dir(path : String)
  cache = Hash(Int32, Array(MT::MCache)).new { |h, k| h[k] = [] of MT::MCache }

  files = Dir.glob("#{path}/*.hm_eg.mtl")
  files.sort_by! { |f| File.basename(f, ".hm_eg.mtl").to_i }

  files.each do |file|
    data = MT::RawMtlBatch.from_file(file).to_mcache
    data.each { |entry| cache[entry.tok[0].ord % 2**10] << entry }
  rescue ex
    puts "#{file}: #{ex}"
    File.open("/2tb/var.chivi/cache/mcache-errors.log", "a") { |f| f.puts "#{file}: #{ex}" }
  end

  puts "#{path}: #{cache.each_value.sum(&.size)}"

  cache.each do |block, items|
    MT::MCache.load_db(block, "ern_g").open_tx do |db|
      items.each(&.upsert!(db: db))
    end
  end
end

INP = "/srv/chivi/zroot/corpus/yscrit"
chilren = Dir.children(INP).sort_by!(&.to_i)
chilren.each { |child| import_dir "#{INP}/#{child}" }
