DELETE = ARGV.includes?("--delete")

DIR = "var/chtexts/jx_la"
Dir.each_child(DIR) do |child|
  next if child == "_"
  dir = File.join(DIR, child)

  missing = 0
  Dir.glob("#{dir}/*.tsv").each do |file|
    missing += 1 unless File.exists?(file.sub(".tsv", ".zip"))
  end

  next if missing < 2

  puts "#{dir} is missing #{missing} zip files"
  `rm -rf #{dir}/*.zip` if DELETE
end
