# require "json"
require "colorize"

INP = "_db/prime/chdata/texts"
SSH = "deploy@ssh.chivi.xyz"
OUT = "#{SSH}:www/chivi/#{INP}"

def upload_texts(seed)
  indir = File.join(INP, seed)
  files = Dir.glob(File.join(indir, "*.zip"))

  puts "[#{seed}: #{files.size} files]".colorize.cyan

  files.each_with_index do |file, idx|
    puts "-- <#{idx + 1}/#{files.size}> [#{seed}/#{File.basename(file)}]".colorize.blue

    puts file
    puts `rsync -azi --no-p #{file} #{OUT}/#{seed}`
  rescue err
    puts err.colorize.red
  end
end

seeds = ARGV.empty? ? Dir.children(INP) : ARGV
puts "INPUT: #{seeds}".colorize.yellow

seeds.each do |seed|
  puts `ssh #{SSH} mkdir -p www/chivi/#{INP}/#{seed}`
  upload_texts(seed)
end
