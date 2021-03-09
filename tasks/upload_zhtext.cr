#!/usr/bin/crystal

# require "json"
require "colorize"

INP = "_db/chdata/zhtexts"
SSH = "nipin@ssh.chivi.xyz"
OUT = "#{SSH}:www/chivi.xyz/#{INP}"

def upload_texts(sname : String)
  dirs = Dir.glob(File.join(INP, sname, "*/"))
  dirs.sort_by! { |x| File.basename(x).to_i? || 0 }

  dirs.each_with_index(1) do |txt_dir, i|
    snvid = File.basename(txt_dir)
    `ssh #{SSH} mkdir -p /home/nipin/www/chivi.xyz/#{INP}/#{sname}/#{snvid}`

    files = Dir.glob(File.join(txt_dir, "*.zip"))
    puts "- <#{i}/#{dirs.size}> [#{sname}/#{snvid}]: #{files.size} files".colorize.cyan

    files.each_with_index(1) do |file, idx|
      puts "-- <#{idx}/#{files.size}> [#{file}]".colorize.blue
      res = `rsync -ai --no-p "#{file}" "#{OUT}/#{sname}/#{snvid}"`
      puts res.empty? ? "  existed, skipping!".colorize.dark_gray : res.colorize.yellow
    end
  end
end

existed = Dir.children(INP)
snames = ARGV.empty? ? existed : ARGV.select { |x| existed.includes?(x) }

puts "INPUT: #{snames}".colorize.yellow.bold
snames.each { |sname| upload_texts(sname) }
