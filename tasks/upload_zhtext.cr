#!/usr/bin/crystal

# require "json"
require "colorize"

INP = "_db/chdata/zhtexts"
SSH = "nipin@dev.chivi.xyz"
OUT = "#{SSH}:www/chivi.xyz/#{INP}"

def upload_texts(s_name : String, flags = "")
  puts `ssh #{SSH} mkdir -p /home/nipin/www/chivi.xyz/#{INP}/#{s_name}`

  files = Dir.glob(File.join(INP, s_name, "*.zip"))
  puts "[#{s_name}: #{files.size} files]".colorize.cyan

  files.sort_by! { |x| File.basename(x, ".zip").to_i } unless s_name == "zhwenpg"
  files.each_with_index(1) do |file, idx|
    puts "-- <#{idx}/#{files.size}> [#{s_name}/#{File.basename(file)}]".colorize.blue
    puts `rsync -ai --no-p #{flags} "#{file}" "#{OUT}/#{s_name}"`
  rescue err
    puts err.colorize.red
  end
end

existed = Dir.children(INP)
s_names = ARGV.empty? ? existed : ARGV.select { |x| existed.includes?(x) }

if ARGV.includes?("--delete")
  flags = "--delete"
elsif ARGV.includes?("--ignore")
  flags = "--ignore-existing"
else
  flags = ""
end

puts "[INPUT: #{s_names}, FLAGS: #{flags}]".colorize.yellow.bold
s_names.each { |s_name| upload_texts(s_name, flags) }
