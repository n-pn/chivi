#!/usr/bin/crystal

# require "json"
require "colorize"

INP = "_db/chdata/zhtexts"
SSH = "nipin@ssh.chivi.xyz"
OUT = "#{SSH}:www/chivi.xyz/#{INP}"

def upload_texts(sname : String)
  seed_dir = File.join(INP, sname)
  `ssh #{SSH} mkdir -p /home/nipin/www/chivi.xyz/#{seed_dir}`

  dirs = Dir.children(seed_dir).sort_by { |x| x.to_i? || 0 }

  dirs.each_with_index(1) do |snvid, idx|
    text_dir = File.join(seed_dir, snvid)
    puts "- <#{idx}/#{dirs.size}> [#{text_dir}]".colorize.cyan
    puts `rsync -aiWS --inplace --no-p "#{text_dir}" "#{OUT}/#{sname}"`.colorize.yellow
  end
end

existed = Dir.children(INP)
snames = ARGV.empty? ? existed : ARGV.select { |x| existed.includes?(x) }

puts "INPUT: #{snames}".colorize.yellow.bold
snames.each { |sname| upload_texts(sname) }
