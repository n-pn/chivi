require "mime"
require "digest"
require "colorize"
require "http/client"
require "file_utils"

require "../src/models/book_info"

TLS = OpenSSL::SSL::Context::Client.insecure

TMP_DIR = File.join("data", ".inits", "txt-tmp", "covers")
OUT_DIR = File.join("data", "covers")

DEFAULT = File.join(OUT_DIR, "blank.jpg")

def download_cover(url : String, file : String, label = "1/1")
  uri = URI.parse(url)
  return unless uri.host && uri.full_path

  tls = url.starts_with?("https") ? TLS : false # TODO: check by uri?
  http = HTTP::Client.new(uri.host.not_nil!, tls: tls)

  http.dns_timeout = 20
  http.connect_timeout = 30
  http.read_timeout = 60

  http.get(uri.full_path.not_nil!) do |res|
    # if ext = MIME.extensions(res.mime_type.to_s).first?
    #   if ext != ".jpg" || ext != ".jpeg"
    #     puts "#{url.colorize(:yellow)} : #{ext.colorize(:yellow)}"
    #   end
    # end
    File.write(file, res.body_io.try(&.gets_to_end))
    puts "- <#{label.colorize(:blue)}> [#{url.colorize(:blue)}]"
  rescue err
    FileUtils.cp(DEFAULT, file)
    puts "- <#{label.colorize(:red)}> [#{url.colorize(:red)}] #{err.colorize(:red)}"
  end
end

SKIP_EMPTY = ARGV.includes?("skip_empty")

def glob_dir(dir : String)
  glob = {} of String => String

  Dir.children(dir).each do |file|
    name = file.split(".", 2).first
    file = File.join(dir, file)

    next if SKIP_EMPTY && File.size(file) == 0
    glob[name] = file
  end

  glob
end

queue = [] of Tuple(String, String)

infos = BookInfo.load_all
infos.values.sort_by(&.tally.-).each_with_index do |info, idx|
  puts "- <#{idx + 1}/#{infos.size}> #{info.vi_title}".colorize(:cyan)

  cover_dir = File.join(OUT_DIR, info.uuid)
  FileUtils.mkdir_p(cover_dir)
  indexed = glob_dir(cover_dir)

  info.covers.each do |cover|
    name = Digest::SHA1.hexdigest(cover)[0..10]
    next if indexed.has_key?(name)

    queue << {cover, File.join(cover_dir, name + ".jpg")}
  end
end

puts "- pending: #{queue.size}"

limit = 20
limit = queue.size if queue.size < limit

channel = Channel(Nil).new(limit)

queue.each_with_index do |(url, file), idx|
  channel.receive if idx >= limit
  spawn do
    download_cover(url, file, "#{idx + 1}/#{queue.size}")
  ensure
    channel.send(nil)
  end
end

limit.times { channel.receive }

WEB_DIR = File.join("web", "upload", "covers")

# TODO: copy best covers to web/upload folder
infos.each_with_index do |(uuid, info), idx|
  puts "- <#{idx + 1}/#{infos.size}> #{info.vi_title}"

  best_file = DEFAULT
  best_size = File.size(best_file)

  cover_dir = File.join(OUT_DIR, info.uuid)
  cover_files = glob_dir(cover_dir).values

  cover_files.each do |file|
    size = File.size(file)
    if size > best_size
      best_file = file
      best_size = size
    end
  end

  out_file = File.join(WEB_DIR, "#{uuid}.jpg")
  FileUtils.cp(best_file, out_file)
end
