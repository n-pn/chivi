require "../src/_utils/zip_store"

INP = "_db/seeds"

Dir.children(INP).each do |seed|
  puts "- #{seed}"

  source = File.join(INP, seed, "raw-infos")
  next unless File.exists?(source)
  # TODO: compress html files to gzip
end
