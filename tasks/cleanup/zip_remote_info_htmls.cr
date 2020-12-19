require "../src/shared/file_utils"

INP = "_db/.cache"

Dir.children(INP).each do |seed|
  puts "- #{seed}"

  dir = File.join(INP, seed, "infos")
  next unless File.exists?(dir)
  files = Dir.glob("#{dir}/*.html")

  files.each_with_index do |file, idx|
    puts "- <#{idx + 1}/#{files.size}> #{file}".colorize.blue
  end
end
