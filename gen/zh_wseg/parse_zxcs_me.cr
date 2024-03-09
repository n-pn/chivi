dirs = Dir.children("/www/chivi/anlzs/zxcs_me")

dirs.each do |sn_id|
  out_hash = Hash(String, Int32).new(0)

  inp_paths = Dir.glob("/www/chivi/anlzs/zxcs_me/#{sn_id}/*.tok")

  inp_paths.each do |inp_path|
    File.each_line(inp_path) do |line|
      line.split('\t') do |word|
        out_hash[word] &+= 1
      end
    end
  end

  out_path = "/www/chivi/freqs/zxcs_me-#{sn_id}.tsv"

  File.open(out_path, "w") do |file|
    out_hash.to_a.sort_by!(&.[1].-).each do |word, freq|
      file << word << '\t' << freq << '\n'
    end
  end

  puts "#{out_path} saved!"
end
