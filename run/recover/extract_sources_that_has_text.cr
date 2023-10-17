out_file = "/2tb/tmp.chivi/has_text.tsv"
checked = File.read_lines(out_file).to_set

INP = "/media/nipin/Vault/Asset/chivi_db/chtexts"

Dir.children(INP).each do |sname|
  inp_dir = File.join(INP, sname)

  Dir.children(inp_dir).each do |sn_id|
    fname = File.join(inp_dir, sn_id, "0.zip")
    next if checked.includes?(fname)

    if info = File.info?(fname)
      puts fname
      File.open(out_file, "a", &.puts "#{fname}\t#{info.size}\t#{info.modification_time.to_unix}")
    else
      File.open(out_file, "a", &.puts "#{fname}\t0\t0")
    end
  rescue ex
    puts ex
  end

  sleep 10.seconds
end
