require "mime"
require "digest"
require "colorize"
require "http/client"
require "file_utils"

require "../../src/models/book_info"

TMP_DIR = File.join("var", ".book_cover")
# FILE_DF = File.join(TMP_DIR, "blank.jpg")

TLS = OpenSSL::SSL::Context::Client.insecure

def download_cover(url : String, file : String, label = "1/1") : Void
  return if !SKIP_EMPTY && File.exists?(file)

  puts "- <#{label}> [#{url.colorize(:blue)}]"

  uri = URI.parse(url)
  return unless uri.host && uri.full_path

  tls = url.starts_with?("https") ? TLS : false # TODO: check by uri?
  http = HTTP::Client.new(uri.host.not_nil!, tls: tls)

  http.dns_timeout = 10
  http.connect_timeout = 10
  http.read_timeout = 30

  http.get(uri.full_path.not_nil!) do |res|
    # if ext = MIME.extensions(res.mime_type.to_s).first?
    #   if ext != ".jpg" || ext != ".jpeg"
    #     puts "#{url.colorize(:yellow)} : #{ext.colorize(:yellow)}"
    #   end
    # end
    File.write(file, res.body_io.try(&.gets_to_end))
  end
rescue err
  FileUtils.touch(file)
  puts "- <#{label}> [#{url.colorize(:red)}] #{err.colorize(:red)}"
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

infos = BookInfo.load_all!
infos.each do |info|
  cover_dir = File.join(TMP_DIR, info.ubid)
  FileUtils.mkdir_p(cover_dir)
  indexed = glob_dir(cover_dir)

  info.cover_urls.each do |site, cover|
    next if cover.empty? # || site == "jx_la" || site == "paoshu8"

    unless cover.starts_with?("http")
      puts info.to_json
      gets
    end

    name = Digest::SHA1.hexdigest(cover)[0..10]
    next if indexed.has_key?(name)

    queue << {cover, File.join(cover_dir, name + ".jpg")}
  end
end

puts "- pending: #{queue.size}"

unless queue.size < 12
  limit = 12
  limit = queue.size if queue.size < limit

  channel = Channel(Nil).new(limit)

  queue.each_with_index do |(url, file), idx|
    channel.receive unless idx < limit
    spawn do
      download_cover(url, file, "#{idx + 1}/#{queue.size}")
    ensure
      channel.send(nil)
    end
  end

  limit.times { channel.receive }
end

OUT_DIR = File.join("web", "public", "covers")
FileUtils.mkdir_p(OUT_DIR)

# TODO: copy best covers to web/upload folder
infos.each do |info|
  best_file = ""
  best_size = 0

  cover_dir = File.join(TMP_DIR, info.ubid)
  cover_files = glob_dir(cover_dir).values

  cover_files.each do |file|
    size = File.size(file)

    if size > best_size
      best_file = file
      best_size = size
    end
  end

  next if best_file.empty?

  main_cover = File.basename(best_file)
  info.main_cover = main_cover
  next unless info.changed?

  info.save!
  out_file = File.join(OUT_DIR, "#{info.ubid}.#{main_cover}")
  FileUtils.cp(best_file, out_file)
end
