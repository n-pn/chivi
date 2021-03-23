#!/usr/bin/crystal

# require "json"
require "colorize"

SSH = "nipin@ssh.chivi.xyz"
INP = "_db/chdata/zhtexts"
OUT = "/home/nipin/srv/chivi.xyz"

def upload_texts(sname : String)
  seed_dir = File.join(INP, sname)
  remote_dir = "#{OUT}/#{seed_dir}"
  puts `ssh #{SSH} mkdir -p "#{remote_dir}"`

  dirs = Dir.children(seed_dir).sort_by { |x| x.to_i? || 0 }

  threads = dirs.size
  threads = 8 if threads > 8
  channel = Channel(Nil).new(threads + 1)

  dirs.each_with_index(1) do |snvid, idx|
    channel.receive if idx > threads

    spawn do
      text_dir = File.join(seed_dir, snvid)
      puts "- <#{idx}/#{dirs.size}> [#{text_dir}]".colorize.cyan
      puts `rsync -aiWS --inplace --no-p -e "ssh -T -c aes128-ctr -o Compression=no -x" "#{text_dir}" "#{SSH}:#{remote_dir}"`.colorize.yellow
      channel.send(nil)
    end
  end

  threads.times { channel.receive }
end

existed = Dir.children(INP)
snames = ARGV.empty? ? existed : ARGV.select { |x| existed.includes?(x) }

puts "-- INPUT: #{snames} --".colorize.yellow.bold
snames.each { |sname| upload_texts(sname) }
