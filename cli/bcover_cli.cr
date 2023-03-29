require "colorize"
require "option_parser"
require "http/client"
require "compress/gzip"

require "../src/_util/hash_util"

DIR = "var/files/covers"
Dir.mkdir_p(DIR)

MAX_WIDTH = 300

def dead_link?(link : String)
  link =~ /bxwxorg|biqugee|jx.la|zhwenpg|shubaow/
end

def image_path(name : String, ext : String = ".jpg")
  File.join(DIR, "#{name}#{ext}")
end

def map_extension(mime : String?) : String
  case mime
  when .nil?        then ".raw"
  when "image/jpeg" then ".jpg"
  when "image/png"  then ".png"
  when "image/gif"  then ".gif"
  when "image/webp" then ".webp"
  when "text/html"  then ".html"
  else
    MIME.extensions(mime).first? || ".jpg"
  end
end

def valid_extension?
  !self.ext.in?(".raw", ".html", ".ascii")
end

def image_width(path : String) : Int32
  result = `identify -format '%w %h' '#{path}'`
  return -1 unless $?.success?
  result.split(' ', 2).first.to_i
rescue
  -1
end

def fetch_image(link : String, name : String) : String
  ext = ".jpg"
  path = image_path(name, ext)

  HTTP::Client.get(link) do |res|
    _ext = map_extension(res.content_type)
    path = path.sub(ext, _ext)
    ext = _ext

    if res.headers["Content-Encoding"]? == "gzip"
      Compress::Gzip::Reader.open(res.body_io) { |io| File.write(path, io.gets_to_end) }
    else
      File.write(path, res.body_io)
    end
  end

  path
end

def img_to_webp(orig_path : String, webp_path : String) : Bool
  if orig_path.ends_with?(".gif")
    Process.run "gif2webp -quiet '#{orig_path}' -o '#{webp_path}'", shell: true
  else
    webp_cmd = "cwebp '#{orig_path}' -o '#{webp_path}' -quiet -q 100 -mt"
    webp_cmd += " -resize #{MAX_WIDTH} 0" if image_width(orig_path) > MAX_WIDTH
    Process.run(webp_cmd, shell: true)
  end

  File.file?(webp_path)
end

link = ""
name = ""
redo = false

OptionParser.parse(ARGV) do |parser|
  parser.on("-f", "Force redo") { redo = true }

  parser.on("-i LINK", "Image link") { |x| link = x.strip }
  parser.on("-n NAME", "Image name") { |x| name = x.strip }
end

name = HashUtil.digest32(link, 8) if name.empty?

puts "LINK: #{link}, NAME: #{name}"

exit 1 if link.empty? || dead_link?(link)

webp_path = image_path(name, ".webp")

if redo || !File.file?(webp_path)
  orig_path = fetch_image(link: link, name: name)
  exit 1 unless File.file?(orig_path) && img_to_webp(orig_path, webp_path)
end

puts "WEBP: #{name}.webp"
