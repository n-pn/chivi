#!/usr/bin/crystal

# require "json"
require "colorize"

INP = "_db/chdata/zhtexts"
SSH = "nipin@ssh.chivi.xyz"
OUT = "#{SSH}:www/chivi.xyz/#{INP}"

def upload_texts(sname : String, flags = "")
  puts `ssh #{SSH} mkdir -p /home/nipin/www/chivi.xyz/#{INP}/#{sname}`

  files = Dir.glob(File.join(INP, sname, "*.zip"))
  puts "[#{sname}: #{files.size} files]".colorize.cyan

  files.sort_by! { |x| File.basename(x, ".zip").to_i } unless sname == "zhwenpg"
  channel = Channel(Nil).new(8)

  files.each_with_index(1) do |file, idx|
    channel.receive if idx > 8

    spawn do
      puts "-- <#{idx}/#{files.size}> [#{sname}/#{File.basename(file)}]".colorize.blue
      puts `rsync -ai --no-p #{flags} "#{file}" "#{OUT}/#{sname}"` || "<#{file}> existed!"
    rescue err
      puts err.colorize.red
    ensure
      channel.send(nil)
    end
  end

  8.times { channel.receive }
end

existed = Dir.children(INP)
snames = ARGV.empty? ? existed : ARGV.select { |x| existed.includes?(x) }

if ARGV.includes?("--delete")
  flags = "--delete"
elsif ARGV.includes?("--ignore")
  flags = "--ignore-existing"
else
  flags = ""
end

puts "[INPUT: #{snames}, FLAGS: #{flags}]".colorize.yellow.bold
snames.each { |sname| upload_texts(sname, flags) }
