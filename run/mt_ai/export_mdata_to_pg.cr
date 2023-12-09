require "../../src/mt_ai/data/m_cache"
require "../../src/mt_ai/data/m_cache_pg"

DIR = "/2tb/var.chivi/cache/mdata"

["ele_s", "ele_b", "ern_g"].each_with_index(1) do |type, ver|
  files = Dir.glob("#{DIR}/*.#{type}.db3")
  files.sort_by! { |x| File.basename(x, ".#{type}.db3").to_i }
  files = files.select { |x| File.basename(x, ".#{type}.db3").to_i > 800 } if type == "ele_s"

  files.each do |db_path|
    entries = DB.open("sqlite3:#{db_path}") do |db|
      db.query_all "select * from mcache", as: MT::MCache
    end

    outputs = entries.compact_map do |entry|
      next if entry.con.empty?

      output = MT::MCachePG.new(
        ver: ver.to_i16,
        tok: entry.tok.split('\t'),
        mtime: 0,
      )

      output.con = MT::RawCon.from_json(entry.con)

      unless entry.dep.empty?
        output.dep = Array(MT::RawDep).from_json(entry.dep) rescue ""
      end

      ner = [] of MT::RawEnt

      unless entry.msra.empty?
        ner.concat Array(MT::RawEnt).from_json(entry.msra)
      end

      unless entry.onto.empty?
        ner.concat Array(MT::RawEnt).from_json(entry.onto)
      end

      output.ner = ner unless ner.empty?

      output
    end

    MT::MCachePG.db.transaction do |tx|
      outputs.each(&.upsert!(db: tx.connection))
    end

    puts "#{db_path}: saved: #{outputs.size}"
  end
end
