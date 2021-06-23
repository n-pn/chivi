#!/usr/bin/crystal

# require "json"
require "colorize"

module CV::UploadSeed
  extend self

  INP = "_db/chseed"
  OUT = "/home/nipin/srv/chivi.xyz"

  def upload_all!(snames : Array(String))
    puts "-- INPUT: #{snames} --".colorize.yellow.bold

    channel = Channel(Nil).new(snames.size)

    if ARGV.includes?("-prod")
      ssh = "nipin@ssh.chivi.xyz"
    else
      ssh = "nipin@dev.chivi.xyz"
    end

    snames.each do |sname|
      spawn do
        upload!(sname, ssh)
      ensure
        channel.send(nil)
      end
    end

    snames.size.times { channel.receive }
  end

  def upload!(sname : String, ssh = "nipin@ssh.chivi.xyz")
    target_dir = File.join(INP, sname)
    remote_dir = "#{OUT}/#{target_dir}"

    puts `ssh #{ssh} mkdir -p "#{remote_dir}"`

    dirs = Dir.children(target_dir).sort_by { |x| x.to_i? || 0 }

    threads = dirs.size
    threads = 8 if threads > 8
    channel = Channel(Nil).new(threads + 1)

    command = %{rsync -aiWS --inplace --no-p -e "ssh -T -c aes128-ctr -o Compression=no -x"}

    dirs.each_with_index(1) do |snvid, idx|
      channel.receive if idx > threads

      spawn do
        text_dir = File.join(target_dir, snvid)
        puts "- <#{idx}/#{dirs.size}> [#{text_dir}]".colorize.cyan
        puts `#{command} "#{text_dir}" "#{ssh}:#{remote_dir}"`.colorize.yellow
        channel.send(nil)
      end
    end

    threads.times { channel.receive }
  end
end

existed = Dir.children(CV::UploadSeed::INP)
uploads = ARGV.select { |x| existed.includes?(x) }
uploads = existed if uploads.empty?

CV::UploadSeed.upload_all!(uploads)
