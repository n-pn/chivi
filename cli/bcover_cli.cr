require "log"
require "http/client"
require "colorize"
require "../src/_util/ukey_util"

def save_image(link : String, file : String, webp_file : String)
  return if File.exists?(webp_file) || link.blank?
  return unless img_file = fetch_image(link, file)

  if img_file.ends_with?(".gif")
    gif_to_webp(img_file, webp_file)
  elsif img_width = image_width(img_file)
    img_to_webp(img_file, webp_file, img_width)
  end
end

def fetch_image(link : String, img_file : String) : String?
  return img_file if File.exists?(img_file)
  Log.info { "Fetch image: #{link}" }

  HTTP::Client.get(link) do |res|
    ext = map_extension(res.content_type)
    img_file = img_file.sub(".jpg", ext)

    Dir.mkdir_p(File.dirname(img_file))
    File.write(img_file, res.body_io)
  end

  Log.info { "[#{link}] saved to [#{img_file}]".colorize.yellow }
  img_file
rescue err
  Log.error { err.colorize.red }
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
    exts = MIME.extensions(mime)
    exts.empty? ? ".jpg" : exts.first
  end
end

def image_width(file : String, delete = false) : Int32?
  return unless File.exists?(file)
  `identify -format '%w %h' "#{file}"`.split(" ").first.to_i?
rescue err
  Log.error { [file, err].colorize.red }
  File.delete(file) if delete
end

def gif_to_webp(inp_file : String, out_file : String)
  `gif2webp -quiet "#{inp_file}" -o "#{out_file}"`
  return unless width = image_width(out_file)
  img_to_webp(out_file, out_file, width)
end

def img_to_webp(inp_file : String, out_file : String, width = 300)
  webp_cmd = "cwebp -quiet -q 100 -mt"
  webp_cmd += " -resize 300 0" if width > 300
  webp_cmd += %{ "#{inp_file}" -o "#{out_file}"}
  `#{webp_cmd}`
end

image_url = ARGV[0]

webm_name = ARGV[1]? || CV::UkeyUtil.digest32(image_url, 8) + ".webp"
webm_path = "priv/static/covers/#{webm_name}"

image_dir = ARGV[2]? || "users"
image_name = ARGV[3]? || webm_name.sub(".webp", ".jpg")
image_path = "_db/bcover/#{image_dir}/#{image_name}"

save_image(image_url, image_path, webm_path)
