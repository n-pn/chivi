#!/usr/bin/crystal

# require "json"
require "colorize"

INP = "_db/zhtext"
# SSH = "deploy@dev.chivi.xyz"
SSH = "nipin@ssh.chivi.xyz"
OUT = "#{SSH}:www/chivi/_db/zhtext"

def upload_texts(seed, flags = "")
  puts `ssh #{SSH} mkdir -p /home/nipin/www/chivi/_db/zhtext/#{seed}`

  seed_dir = File.join(INP, seed)
  children = Dir.glob(File.join(seed_dir, "*.zip"))

  puts "[#{seed}: #{children.size} files]".colorize.cyan

  children.each_with_index do |file, idx|
    puts "-- <#{idx + 1}/#{children.size}> [#{seed}/#{File.basename(file)}]".colorize.blue
    puts `rsync -ai --no-p #{flags} #{file} #{OUT}/#{seed}`
  rescue err
    puts err.colorize.red
  end
end

exist = Dir.children(INP)
seeds = ARGV.empty? ? exist : ARGV.select { |x| exist.includes?(x) }

if ARGV.includes?("--delete")
  flags = "--delete"
elsif ARGV.includes?("--ignore")
  flags = "--ignore-existing"
else
  flags = ""
end

puts "[INPUT: #{seeds}, FLAGS: #{flags}]".colorize.yellow.bold
seeds.each { |seed| upload_texts(seed, flags) }
