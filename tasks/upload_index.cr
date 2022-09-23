require "http/client"

module CV
  extend self
  DIR = "var/chtexts"
  SSH = "nipin@ssh.chivi.app:srv/chivi/#{DIR}"

  def upload(sname : String, redo = false, sync = false)
    s_dir = File.join(DIR, sname)
    files = Dir.glob("#{s_dir}/*/index.db")
    return if files.empty?

    puts "\n uploading [#{s_dir}]: #{files.size} files"

    workers = files.size
    workers = 6 if workers > 6
    channel = Channel(Nil).new(workers)

    files.each_with_index(1) do |index_file, idx|
      channel.receive if idx > workers

      spawn do
        if redo || !already_uploaded?(index_file)
          log_result(index_file) if upload_file(index_file)
        end
      ensure
        channel.send(nil)
      end
    end

    workers.times { channel.receive }
    return unless sync

    system("rsync", {
      "-ai", "--no-p",
      "--include='*.r2'",
      "--include='*/'",
      "--exclude='*'",
      s_dir, SSH,
    })
  end

  def log_result(db_file : String)
    r2_file = db_file.sub(".db", ".r2")

    time = File.info(db_file).modification_time + 1.minutes
    size = File.size(db_file)

    File.write(r2_file, [time, size].join('\t'))
    puts "-- #{db_file} uploaded"
  end

  def already_uploaded?(db_file : String)
    r2_file = db_file.sub(".db", ".r2")
    return false unless File.exists?(r2_file)

    db_utime = File.info(db_file).modification_time
    r2_utime = File.info(r2_file).modification_time
    r2_utime + 2.minutes >= db_utime
  end

  def upload_file(inp_file : String) : String?
    url = inp_file.sub("var/chtexts", "https://r2.chivi.app/texts")
    headers = HTTP::Headers{"X-Custom-Auth-Key" => ENV["R2_AUTH"]}

    res = HTTP::Client.put(url, headers, body: File.read(inp_file))
    url if res.status_code < 400
  rescue err
    puts err
  end

  def run!(argv = ARGV)
    redo = ARGV.includes?("--redo")
    sync = ARGV.includes?("--sync")

    ARGV.each do |sname|
      next if sname.starts_with?("-")
      upload(sname, redo: redo, sync: sync)
    end
  end

  run!(ARGV)
end
