TXT_DIR = "var/chtexts/zxcs_me"
R2_ROOT = "https://cr2.chivi.app/texts/zxcs_me"

def download_file(file : String)
  zip_file = file.sub(".tab", ".zip")
  return if File.exists?(zip_file)

  cdn_url = zip_file.sub(TXT_DIR, R2_ROOT)
  puts "- GET: #{cdn_url}"

  message = `curl -L -k -s -m 30 "#{cdn_url}" -o #{zip_file}`
  puts message unless $?.success?
end

files = Dir.glob("#{TXT_DIR}/*/*.tab")

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
