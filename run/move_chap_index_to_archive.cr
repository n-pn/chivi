def move_seed(sname : String)
  out_dir = "/mnt/extra/Asset/chivi_db/chaps/old-infos/#{sname}"
  puts "output: #{out_dir}"
  Dir.mkdir_p(out_dir)

  files = Dir.glob("var/chaps/texts/#{sname}/**/index.db")

  files.each_with_index(1) do |file, idx|
    s_bid = File.basename(file, "/index.db")
    out_file = "#{out_dir}/#{s_bid}-infos.db"

    puts "- #{idx}/#{files.size}: #{file} => #{out_file}"
    `mv '#{file}' '#{out_file}'`
  end
end

snames = ARGV
snames = Dir.children("var/chaps/texts") if snames.empty?
snames.each { |sname| move_seed(sname) }
