require "http/client"
require "./_store"
require "../../_util/r2_client"
require "../../_util/ukey_util"

class CV::Bcover
  DIR = ENV["COVER_DIR"]? || "var/books/cover"
  # Dir.mkdir_p(DIR)

  MAX_WIDTH = 300

  include TsvStore

  property name : String = ""
  property link : String = ""
  property format : String = ".jpg" # original image extension

  property width : Int32 = 0    # image width
  property on_r2 : Bool = false # uploaded to cloudflare r2

  getter webp_name : String { @name + ".webp" }
  getter webp_path : String { File.join(DIR, webp_name) }

  def valid?
    !@format.in?(".raw", ".html")
  end

  def exists?
    File.exists?(webp_path)
  end

  def fetch!(force = false) : Bool
    image_path = File.join(DIR, @name + @format)
    return true if !force && File.exists?(image_path)

    HTTP::Client.get(@link) do |res|
      format = map_extension(res.content_type)

      image_path = image_path.sub(self.format, format)
      self.format = format

      if res.headers["Content-Encoding"]? == "gzip"
        gz_image_path = image_path + ".gz"
        File.write(gz_image_path, res.body_io)
        `gzip -d #{gz_image_path}`
        return $?.success?
      else
        File.write(image_path, res.body_io)
      end
    end

    puts "- Fetching: #{@link}"
    File.exists?(image_path)
  end

  def to_webp!(force = false)
    puts "- Save [#{@link}] as webp"

    return false if !force && File.exists?(webp_path)

    orig_path = File.join(DIR, @name + @format)
    return false unless File.exists?(orig_path)

    self.width = image_width(orig_path)
    return false if self.width == 0

    resize = self.width > MAX_WIDTH

    if @format == ".gif"
      gif_to_webp(orig_path, webp_path, resize: resize)
    else
      img_to_webp(orig_path, webp_path, resize: resize)
    end
  end

  def to_r2! : Bool
    image_path = File.join(DIR, webp_name)
    image_href = "covers/#{webp_name}"
    return false unless File.exists?(image_path)
    self.on_r2 = R2Client.upload(image_href, image_path)
    self.on_r2
  end

  private def gif_to_webp(inp_path : String, out_path : String, resize = false)
    `gif2webp -quiet "#{inp_path}" -o "#{out_path}"`
    return false unless $?.success?
    resize ? img_to_webp(out_path, out_path, resize: true) : true
  end

  private def img_to_webp(inp_file : String, out_file : String, resize = false)
    webp_cmd = "cwebp -quiet -q 100 -mt"
    webp_cmd += " -resize #{MAX_WIDTH} 0" if resize
    webp_cmd += %{ "#{inp_file}" -o "#{out_file}"}
    `#{webp_cmd}`
  end

  private def image_width(path : String) : Int32
    `identify -format '%w %h' "#{path}"`.split(" ").first.to_i
  rescue err
    puts err
    0
  end

  private def map_extension(mime : String?) : String
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

  ####

  def self.init(link : String, name : String = "", reset = false) : self
    name = UkeyUtil.digest32(link, 8) if name.empty?
    item = new(File.join(DIR, name + ".tsv"), reset: reset)

    if item.name.empty?
      item.link = link
      item.name = name
      item.atomic_save!
    end

    item
  end
end
