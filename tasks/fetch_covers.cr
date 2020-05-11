require "mime"
require "digest"
require "colorize"
require "http/client"
require "file_utils"

require "../src/models/book_info"

TLS = OpenSSL::SSL::Context::Client.insecure

TMP_DIR = File.join("data", ".inits", "txt-tmp", "covers")
OUT_DIR = File.join("data", "covers")

def download_cover(url : String, file : String, label = "1/1")
  puts "- <#{label.colorize(:blue)}> [#{url.colorize(:blue)}] => [#{file.colorize(:blue)}]"

  uri = URI.parse(url)
  return unless uri.host && uri.full_path

  tls = url.starts_with?("https") ? TLS : false # TODO: check by uri?
  http = HTTP::Client.new(uri.host.not_nil!, tls: tls)

  http.dns_timeout = 5
  http.read_timeout = 5
  http.connect_timeout = 5

  begin
    res = http.get(uri.full_path.not_nil!)

    if ext = MIME.extensions(res.mime_type.to_s).first?
      if ext != ".jpg" || ext != ".jpeg"
        puts "#{url.colorize(:yellow)} : #{ext.colorize(:yellow)}"
      end
    end

    File.write(file, res.try(&.body_io))
  rescue err
    FileUtils.touch(file)
    puts "- <#{url}>: #{err.colorize(:red)}"
  end
end

def glob_dir(dir : String)
  glob = {} of String => String

  Dir.children(dir).each do |file|
    name = file.split(".", 2).first
    glob[name] = File.join(dir, file)
  end

  glob
end

old_files = glob_dir(TMP_DIR)

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

    if file = old_files[name]?
      puts "- recover #{file.colorize(:yellow)}"
      FileUtils.mv(file, file.sub(TMP_DIR, cover_dir))
    else
      queue << {cover, File.join(cover_dir, name + ".jpg")}
    end
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
    channel.send(nil)
  end
end

limit.times { channel.receive }

WEB_DIR = File.join("web", "upload", "covers")

# TODO: copy best covers to web/upload folder
infos.each_with_index do |(uuid, info), idx|
  puts "- <#{idx + 1}/#{infos.size}> #{info.vi_title}"

  cover_dir = File.join(OUT_DIR, info.uuid)
  FileUtils.mkdir_p(cover_dir)

  cover_files = glob_dir(cover_dir).values
  next if cover_files.empty?

  best_file = cover_files.first
  best_size = File.size(best_file)

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
