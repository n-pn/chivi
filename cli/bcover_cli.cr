require "colorize"
require "option_parser"
require "http/client"
require "compress/gzip"

require "../src/_util/hash_util"

class HTTP::Client
  @connect_timeout = 20.0
  @read_timeout = 40.0
  @write_timeout = 40.0
end

DIR = "var/files/covers"
Dir.mkdir_p(DIR)

MAX_WIDTH = 300

DEAD_LINKS = {
  "https://qidian.qpic.cn/qdbimg/1/300",
  "http://pic.hxcdn.net/www/cover0.jpg",
  "http://pic.hxcdn.net/www/cover1.jpg",
}

DEAD_HOSTS = {
  "yododo",
  "bxwxorg",
  "biqugee",
  "jx\\.la",
  "zhwenpg",
  "shubaow",
  "chuantu",
  "jjwxc",
  "xhhread",
  "kanshu",
  "hxcdn",
  "motie",
  "nofff",
  "aixs\\.org",
  "photo\\.qq\\.com",
  "meowlove",
  "yuanchuangyanyi",
  "nosdn0\\.126\\.net",
  "voidtech\\.cn",
  "read\\.fmx\\.cn",
  "file\\.ihuayue\\.cn",
  "picphotos\\.baidu\\.com",
  "wal8\\.com",
  "s6\\.jpg\\.cm",
  "aliyuncs\\.com",
  "sinaimg\\.cn",
  "pic\\.iqy\\.ink",
}

DEAD_HOSTS_RE = Regex.new("#{DEAD_HOSTS.join('|')}")

def dead_link?(link : String)
  DEAD_HOSTS_RE.matches?(link) || DEAD_LINKS.includes?(link)
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

def valid_extension?(path : String)
  !File.extname(path).in?("", ".raw", ".txt", ".xml", ".html", ".json", ".ascii")
end

def image_width(path : String) : Int32
  result = `gm identify -format '%w' '#{path}'`
  return -1 unless $?.success?
  result.to_i
rescue
  -1
end

def fetch_image(link : String, name : String) : String
  ext_name = ".jpg"
  path = image_path(name, ext_name)

  HTTP::Client.get(link) do |res|
    _ext = map_extension(res.content_type)
    path = path.sub(ext_name, _ext) if _ext != ext_name

    if !res.headers["Content-Encoding"]?.try(&.includes?("gzip"))
      File.open(path, "w") { |file| IO.copy res.body_io, file }
    else
      Compress::Gzip::Reader.open(res.body_io) do |io|
        File.open(path, "w") { |file| IO.copy io, file }
      end
    end
  end

  path
rescue ex
  puts [link, ex.message].colorize.red
  exit 1
end

def img_to_webp(orig_path : String, webp_path : String) : Bool
  if orig_path.ends_with?(".gif")
    Process.run "gif2webp -quiet '#{orig_path}' -o '#{webp_path}'", shell: true
  else
    webp_cmd = "cwebp '#{orig_path}' -o '#{webp_path}' -quiet -q 100 -mt"
    webp_cmd += " -resize #{MAX_WIDTH} 0" if image_width(orig_path) > MAX_WIDTH
    Process.run(webp_cmd, shell: true)
  end

  # `convert #{inp_file} -quality 50 -define webp:lossless=true -resize "#{width}x>" #{out_file}`

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

exit 1 if link.empty? || dead_link?(link)

webp_path = image_path(name, ".webp")

if redo || !File.file?(webp_path)
  orig_path = fetch_image(link: link, name: name)

  exit 1 unless File.file?(orig_path)
  exit 1 unless valid_extension?(orig_path)
  exit 1 unless img_to_webp(orig_path, webp_path)
end

puts "LINK: #{link}, WEBP: #{name}.webp".colorize.yellow
