require "../../src/mt_ai/data/m_cache"

DIR = "/2tb/var.chivi/cache/mdata.old"

["ele_s", "ele_b", "ern_g"].each do |type|
  files = Dir.glob("#{DIR}/*.#{type}.db3")
  cache = {} of Int32 => Array(MT::MCache)

  files.each do |db_path|
    puts db_path

    DB.open("sqlite3:#{db_path}") do |db|
      db.query_each "select * from mcache" do |rs|
        data = rs.read(MT::MCache)
        size = data.tok.count { |x| x != '\t' }
        list = cache[size] ||= [] of MT::MCache
        list << data
      end
    end
  end

  cache.each do |block, entries|
    puts "#{block}: #{entries.size}"
    MT::MCache.db(block, type).open_tx do |db|
      entries.each(&.upsert!(db: db))
    end
  end
end
