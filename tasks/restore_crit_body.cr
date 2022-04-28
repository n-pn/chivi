require "tabkv"

INP = "var/ysinfos/yscrits.old"
OUT = "var/ysinfos/yscrits"

Store = Tabkv(Array(String))

missing = 0
Dir.glob(OUT + "/*.tsv").each do |file|
  output = Store.new(file)
  source = Store.new(file.sub(OUT, INP))

  output.data.each do |id, texts|
    next if texts != ["$$$"]

    if ztext = source[id]?
      puts "recovered: #{id}"
      output.append(id, ztext)
    else
      missing += 1
    end
  end

  output.save!(clean: true)
end

puts "missing: #{missing}"
