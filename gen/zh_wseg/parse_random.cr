dirs = Dir.children("/2tb/hanlp_out")

inp_paths = Dir.glob("/2tb/hanlp_out/*.con")

input = inp_paths.group_by do |inp_path|
  File.basename(inp_path).split('-', 2).first
end

input.each do |sn_id, inp_paths|
  out_hash = Hash(String, Int32).new(0)

  inp_paths.each do |inp_path|
    File.each_line(inp_path) do |line|
      line.split('\t') do |word|
        out_hash[word] &+= 1
      end
    end
  end

  out_path = "/www/chivi/freqs/random/#{sn_id}.tsv"

  File.open(out_path, "w") do |file|
    out_hash.to_a.sort_by!(&.[1].-).each do |word, freq|
      file << word << '\t' << freq << '\n'
    end
  end

  puts "#{out_path} saved!"
end
