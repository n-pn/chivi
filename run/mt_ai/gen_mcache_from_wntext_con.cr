require "../../src/mt_ai/data/m_cache"

def import_dir(path : String, type = "ele_b")
  cache = Hash(Int32, Array(MT::MCache)).new { |h, k| h[k] = [] of MT::MCache }
  files = Dir.glob("#{path}/*con")

  case type
  when "ern_g"
    files.select!(&.matches?(/mtl_3|hmeg|hm_eg/))
  when "ele_b"
    files.select!(&.matches?(/mtl_2|hmeb|hm_eb/))
  when "ele_s"
    files.select!(&.matches?(/mtl_1|hmes|hm_es/))
  end

  return if files.empty?

  files.each do |file|
    lines = File.read_lines(file)

    lines.each do |line|
      next if line.empty? || line == "(TOP )"

      cdata = MT::RawCon.from_text(line)
      toks = cdata.words.map(&.[1])

      cache[toks.sum(&.size)] << MT::MCache.new(
        rid: MT::MCache.gen_rid(toks),
        tok: toks.join('\t'),
        con: cdata.to_json
      )
    end
  rescue ex
    puts "#{file}: #{ex}"
    File.open("/2tb/var.chivi/cache/mcache-errors.log", "a") { |f| f.puts "#{file}\t#{ex}" }
  end

  puts "#{path} (#{type}): #{cache.each_value.sum(&.size)}"

  cache.each do |block, items|
    MT::MCache.load_db(block, type).open_tx do |db|
      items.each(&.upsert_con!(db: db))
    end
  end
end

type = ARGV[0]? || "ele_s"

snames = Dir.children("var/texts")
snames.each do |sname|
  inp_dir = "var/texts/#{sname}"
  chilren = Dir.children(inp_dir).sort_by!(&.to_i)
  chilren.each { |child| import_dir("#{inp_dir}/#{child}", type) }
end
