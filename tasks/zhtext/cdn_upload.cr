require "http/client"

SSH = "nipin@ssh.chivi.app:srv/chivi"

def upload(dir : String, remove_zip = false, sync_log = false)
  files = Dir.glob("#{dir}/*.zip")

  puts "\n uploading [#{dir}]: #{files.size} files"

  workers = files.size
  workers = 6 if workers > 6
  channel = Channel(Nil).new(workers)

  files.each_with_index(1) do |zip_file, idx|
    channel.receive if idx > workers

    spawn do
      unless uploaded?(zip_file)
        next unless object_path = upload_file(zip_file)
        log_result(zip_file, object_path)
        puts "-- #{zip_file} uploaded"
      end

      File.delete(zip_file) if remove_zip && staled?(zip_file)
    ensure
      channel.send(nil)
    end
  end

  workers.times { channel.receive }

  return unless sync_log
  `rsync -azi --no-p --exclude="*.zip" "#{dir}" "#{SSH}/#{File.dirname(dir)}"`
end

def log_result(zip_file : String, object_path : String)
  log_file = zip_file.sub(".zip", ".tab")

  File.open(log_file, "a") do |io|
    io << object_path << "\t"
    io << Time.utc.to_unix << "\t"
    io << File.size(zip_file) << "\n"
  end
end

def uploaded?(zip_file : String)
  log_file = zip_file.sub(".zip", ".tab")
  return false unless File.exists?(log_file)

  zip_utime = File.info(zip_file).modification_time
  log_utime = File.info(log_file).modification_time
  log_utime >= zip_utime
end

def staled?(zip_file : String) : Bool
  zip_utime = File.info(zip_file).modification_time
  zip_utime < Time.utc - 10.days
end

def upload_file(zip_file : String) : String?
  out_path = zip_file.sub("var/chtexts", "https://r2.chivi.app/texts")
  headers = HTTP::Headers{"X-Custom-Auth-Key" => ENV["R2_AUTH"]}
  HTTP::Client.put(out_path, headers, body: File.read(zip_file))
  out_path
rescue err
  puts err
end

def upload_dir(dir_name : String, remove_zip = false, sync_log = false)
  root = "var/chtexts/#{dir_name}"
  dirs = Dir.children(root).sort_by! { |x| x.to_i? || x.to_i64(base: 36) }

  dirs.each do |book_name|
    upload("#{root}/#{book_name}", remove_zip: remove_zip, sync_log: sync_log)
  end
end

remove_zip = ARGV.includes?("--purge")
sync_log = ARGV.includes?("--synclog")

ARGV.each do |name|
  next if name.starts_with?("-")
  upload_dir(name, remove_zip: remove_zip, sync_log: sync_log)
end
