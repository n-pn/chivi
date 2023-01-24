require "colorize"
require "http/client"

TXT_DIR = "var/chaps/texts"
R2_ROOT = "https://cr2.chivi.app/texts"

def download_seed(sname : String)
  seed_dir = "#{TXT_DIR}/#{sname}"

  files = Dir.glob("#{seed_dir}/**/*.tab").select! do |file|
    File.basename(file)[0].in?('1'..'9')
  end

  files.sort_by! do |file|
    s_bid = File.basename(File.dirname(file)).to_i
    s_cid = File.basename(file, ".tab").to_i
    {s_bid, s_cid}
  end

  puts [seed_dir, files.size]

  workers = Channel({String, Int32}).new(files.size + 1)
  threads = 6
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        file, idx = workers.receive
        fetch_zip(file, "#{idx}/#{files.size}")
        results.send(nil)
      end
    end
  end

  files.each_with_index(1) do |file, idx|
    workers.send({file, idx})
  end

  files.size.times { results.receive }
end

def fetch_zip(tab_file : String, label : String) : Nil
  zip_file = tab_file.sub(".tab", ".zip")
  return if File.file?(zip_file) || File.file?(zip_file + ".unzipped")

  HTTP::Client.get(zip_file.sub(TXT_DIR, R2_ROOT)) do |res|
    if res.status.value < 300
      puts "- #{label}: #{zip_file}".colorize.green
      File.write(zip_file, res.body_io)
    else
      puts "- #{label}: #{zip_file}".colorize.red
      File.delete(tab_file)
    end
  end
end

snames = ARGV
snames = Dir.children("var/chaps/texts") if snames.empty?
puts snames.colorize.yellow

snames.each do |sname|
  next if sname[0].in?('@', '.', '=')
  download_seed(sname)
end
