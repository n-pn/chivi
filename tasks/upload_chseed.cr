#!/usr/bin/crystal

# require "json"
require "colorize"

module CV::UploadSeed
  extend self

  INP = "_db/chseed"
  OUT = "/home/nipin/srv/chivi.xyz"

  def run!(argv = ARGV)
    exists = Dir.children(INP)

    snames = ARGV.select { |x| exists.includes?(x) }
    snames = exists if snames.empty?

    host = upload_host(argv)
    snames.each { |sname| upload!(sname, host) }
  end

  private def upload_host(argv = ARGV)
    case argv
    when .includes?("-p"), .includes?("--prod")
      "nipin@ssh.chivi.xyz"
    else
      "nipin@dev.chivi.xyz"
    end
  end

  def upload!(sname : String, host = "nipin@ssh.chivi.xyz")
    puts "upload to: #{host.colorize.blue}, sname: #{sname.colorize.blue}"

    target_dir = File.join(INP, sname)
    remote_dir = "#{OUT}/#{target_dir}"

    `ssh #{host} mkdir -p "#{remote_dir}"`
    return unless $?.success?

    dirs = Dir.children(target_dir).sort_by { |x| x.to_i? || 0 }

    wkrs = dirs.size
    wkrs = 8 if wkrs > 8
    chan = Channel(Nil).new(wkrs + 1)

    cmd = %{rsync -aiWS --inplace --no-p -e "ssh -T -c aes128-ctr -o Compression=no -x"}

    dirs.each_with_index(1) do |snvid, idx|
      chan.receive if idx > wkrs

      spawn do
        text_dir = File.join(target_dir, snvid)
        puts "- <#{idx}/#{dirs.size}> [#{text_dir}]".colorize.cyan
        puts `#{cmd} "#{text_dir}" "#{host}:#{remote_dir}"`.colorize.yellow
        chan.send(nil)
      end
    end

    wkrs.times { chan.receive }
  end
end

CV::UploadSeed.run!
