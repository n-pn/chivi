require "json"
require "mime"
require "digest"
require "colorize"
require "file_utils"
require "http/client"

require "../../src/models/vp_book"
books = Array(VpBook).from_json(File.read("data/txt-tmp/serials.json"))

puts "- books: #{books.size} entries".colorize(:cyan)

class String
  def digest
    Digest::SHA1.hexdigest(self)[0..10]
  end
end

covers = [] of String

books.each do |book|
  urls = book.covers.map do |url|
    url = url.sub("qu.la", "jx.la")
    if url.starts_with?("http://image.qidian.com")
      url = url.sub("http://image.qidian.com/books", "https://qidian.qpic.cn/qdbimg").sub(".jpg", "/300.jpg")
    end

    url
  end

  covers.concat(urls)
end

covers.uniq!

puts "- images: #{covers.size} entries".colorize(:cyan)

OUT_DIR = "data/txt-tmp/covers"
FileUtils.mkdir_p(OUT_DIR)

def extname(url)
  ext = File.extname(url).downcase
  case ext
  when .empty?, .starts_with?(".php"), .starts_with?(".jpg")
    ".jpg"
  else
    ext
  end
end

TLS = OpenSSL::SSL::Context::Client.insecure

def download(url, label = "1/1") : Void
  ext = extname(url)
  file = "#{OUT_DIR}/#{url.digest}#{ext}"
  return if File.exists?(file)

  puts "- saving <#{label.colorize(:blue)}> \
        [ #{url.colorize(:blue)} ] \
        to [ #{file.colorize(:blue)} ]"

  tls = url.starts_with?("https") ? TLS : nil

  HTTP::Client.get(url, tls: tls) do |res|
    exts = MIME.extensions(res.mime_type.to_s)
    unless exts.empty? || exts.includes?(ext)
      puts "Wrong extension for [#{file}], \
            expects [#{exts}], \
            got [#{ext}]".colorize(:red)

      file = file.sub(ext, exts.first)
    end

    File.write(file, res.body_io)
  rescue err
    puts "Error fetching [#{url}]: #{err.colorize(:red)}"
    FileUtils.touch(file)
  end
end

limit = 20
# limit = covers.size if covers.size < limit

channel = Channel(Nil).new(limit)

covers.each_with_index do |url, idx|
  channel.receive if idx >= limit
  spawn do
    download(url, "#{idx + 1}/#{covers.size}")
    channel.send(nil)
  end
end

limit.times { channel.receive }
