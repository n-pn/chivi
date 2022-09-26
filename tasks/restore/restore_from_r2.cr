TXT_DIR = "var/chtexts"
R2_ROOT = "https://cr2.chivi.app/texts"

def download_file(file : String)
  zip_file = file.sub(".tab", ".zip")
  return if File.exists?(zip_file)

  cdn_url = zip_file.sub(TXT_DIR, R2_ROOT)
  puts "- GET: #{cdn_url}"

  message = `curl -L -k -s -m 30 "#{cdn_url}" -o #{zip_file}`
  puts message unless $?.success?
end

def download_files(files : Array(String))
  workers = 6
  channel = Channel(Nil).new(workers)

  files.each_with_index(1) do |file, idx|
    spawn do
      download_file(file)
    ensure
      channel.send(nil)
    end

    channel.receive if idx > workers
  end

  workers.times { channel.receive }
end

def download_seed(sname : String)
  seed_dir = "#{TXT_DIR}/#{sname}"
  book_dirs = Dir.children(seed_dir)

  files = [] of String
  book_dirs.each do |book_dir|
    files.concat Dir.glob("#{seed_dir}/#{book_dir}/*.tab")

    if files.size > 100
      download_files(files)
      files.clear
    end
  end
end

download_seed(ARGV[0])
