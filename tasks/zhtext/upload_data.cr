#!/usr/bin/crystal

# require "json"
require "colorize"

module CV::UploadChseed
  extend self

  INP = "var/chtexts"
  OUT = "/home/nipin/srv/chivi.app"

  def run!(argv = ARGV)
    exists = Dir.children(INP)

    snames = ARGV.select { |x| exists.includes?(x) }
    snames = exists if snames.empty?

    host = upload_host(argv)
    snames.each { |sname| upload!(sname, host) }
  end

  private def upload_host(argv = ARGV)
    case argv
    when .includes?("-d"), .includes?("--dev")
      "nipin@dev.chivi.app"
    else
      "nipin@ssh.chivi.app"
    end
  end

  def upload!(sname : String, host = "nipin@ssh.chivi.app")
    puts "upload to: #{host.colorize.blue}, sname: #{sname.colorize.blue}"

    target_dir = File.join(INP, sname)
    remote_dir = "#{OUT}/#{target_dir}"

    `ssh #{host} mkdir -p "#{remote_dir}"`
    return unless $?.success?

    dirs = Dir.children(target_dir).sort_by { |x| x.to_i? || 0 } # .reverse

    wkrs = dirs.size
    wkrs = 6 if wkrs > 6
    chan = Channel(Nil).new(wkrs + 1)

    cmd = %{rsync -aiWS --inplace --no-p -e "ssh -T -c aes128-ctr -o Compression=no -x"}

    dirs.each_with_index(1) do |snvid, idx|
      chan.receive if idx > wkrs

      spawn do
        text_dir = File.join(target_dir, snvid)
        puts "- <#{idx}/#{dirs.size}> [#{text_dir}]".colorize.cyan
        output = `#{cmd} "#{text_dir}" "#{host}:#{remote_dir}"`
        puts output.empty? ? "Nothing to upload" : output.colorize.yellow
        chan.send(nil)
      end
    end

    wkrs.times { chan.receive }
  end
end

CV::UploadChseed.run!(ARGV)
