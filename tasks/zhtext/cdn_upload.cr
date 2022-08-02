require "http/client"

module CV
  SSH = "nipin@ssh.chivi.app:srv/chivi"

  def upload(dir : String, reupload = false, purge_zip = false, sync_data = false)
    files = Dir.glob("#{dir}/*.zip")
    return if files.empty?

    puts "\n uploading [#{dir}]: #{files.size} files"

    workers = files.size
    workers = 6 if workers > 6
    channel = Channel(Nil).new(workers)

    files.each_with_index(1) do |zip_file, idx|
      channel.receive if idx > workers

      spawn do
        if reupload || !already_uploaded?(zip_file)
          next unless object_path = upload_file(zip_file)
          log_result(zip_file, object_path)
        end

        File.delete(zip_file) if purge_zip && file_staled?(zip_file)
      ensure
        channel.send(nil)
      end
    end

    workers.times { channel.receive }

    upload_logs(dir) if sync_data
  end

  def log_result(zip_file : String, object_path : String)
    log_file = zip_file.sub(".zip", ".tab")

    File.open(log_file, "a") do |io|
      io << object_path << "\t"
      io << Time.utc.to_unix << "\t"
      io << File.size(zip_file) << "\n"
    end

    puts "-- #{zip_file} uploaded"
  end

  def already_uploaded?(zip_file : String)
    log_file = zip_file.sub(".zip", ".tab")
    return false unless File.exists?(log_file)

    zip_utime = File.info(zip_file).modification_time
    log_utime = File.info(log_file).modification_time
    log_utime >= zip_utime
  end

  def file_staled?(file_path : String) : Bool
    file_utime = File.info(file_path).modification_time
    Time.utc - file_utime > 14.days
  end

  def upload_file(inp_file : String) : String?
    url = inp_file.sub("var/chtexts", "https://r2.chivi.app/texts")
    headers = HTTP::Headers{"X-Custom-Auth-Key" => ENV["R2_AUTH"]}

    res = HTTP::Client.put(url, headers, body: File.read(inp_file))
    url if res.status_code < 400
  rescue err
    puts err
  end

  def upload_logs(dir_path : String)
    parent_dir = File.dirname(dir_path)
    `rsync -azi --no-p --exclude="*.zip" "#{dir_path}" "#{SSH}/#{parent_dir}"`
  end

  def upload_dir(dir_name : String, reupload = false, purge_zip = false, sync_data = false)
    root = "var/chtexts/#{dir_name}"
    dirs = Dir.children(root).map { |x| x.to_i64? || x.to_i64(base: 36) }
    # dirs.reject! { |x| x < 128740 }

    dirs.sort!.each do |book_name|
      dir_path = "#{root}/#{book_name}"
      upload(dir_path, reupload: reupload, purge_zip: purge_zip, sync_data: sync_data)
    end
  end

  def run!(argv = ARGV)
    reupload = ARGV.includes?("--redo")
    purge_zip = ARGV.includes?("--purge")
    sync_data = ARGV.includes?("--sync")

    ARGV.each do |name|
      next if name.starts_with?("-")
      upload_dir(name, reupload: reupload, purge_zip: purge_zip, sync_data: sync_data)
    end
  end

  extend self
  run!(ARGV)
end
