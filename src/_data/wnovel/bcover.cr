require "http/client"

require "../../_util/r2_client"
require "../../_util/hash_util"

require "../_base"

class CV::Bcover
  include Clear::Model

  self.table = "bcovers"

  primary_key type: :serial

  column link : String
  column name : String = ""
  column ext : String = ".jpg" # original image extension

  column size : Int32 = 0  # image size
  column width : Int32 = 0 # image width

  column wn_id : Int32 = 0
  column in_use : Bool = false

  column mtime : Int64 = Time.utc.to_unix
  column state : Int16 = 0_i16

  # states
  # - 0: initialized

  # - 1: downloaded but failed
  # - 2: downloaded

  # - 3: converted to webp failed
  # - 4: converted to webp

  # - 5: uploaded to cloudflare r2 but failed
  # - 6: uploaded to cloudflare r2

  def dead_link?
    self.link =~ /bxwxorg|biqugee|jx.la|zhwenpg|shubaow/
  end

  def image_path(ext : String = self.ext)
    File.join(DIR, "#{self.name}#{ext}")
  end

  def download_image!(force = false) : Nil
    return if !force && state > 0_i16

    path = self.image_path(self.ext)

    HTTP::Client.get(self.link) do |res|
      _ext = map_extension(res.content_type)
      path = path.sub(self.ext, _ext)
      self.ext = _ext

      if res.headers["Content-Encoding"]? == "gzip"
        gz_path = path + ".gz"
        # TODO: Unzip it directly here
        File.write(gz_path, res.body_io)
        `gzip -d #{gz_path}`
      else
        File.write(path, res.body_io)
      end
    end

    self.state = File.exists?(path) ? 2_i16 : 1_i16
    self.save!

    Log.debug { "- Saved #{self.link} to #{path}" }
  end

  DIR = "var/files/covers"
  Dir.mkdir_p(DIR)

  MAX_WIDTH = 300

  def convert_to_webp!(force = false) : Nil
    return if !force && self.state > 2_i16

    orig_path = self.image_path(self.ext)
    webp_path = self.image_path(".webp")

    self.width = read_image_width(orig_path)
    resize = self.width > MAX_WIDTH

    if self.ext == ".gif"
      success = gif_to_webp(orig_path, webp_path, resize: resize)
    else
      success = img_to_webp(orig_path, webp_path, resize: resize)
    end

    self.state = success ? 4_i16 : 3_i16
    Log.debug { "- Saved [#{self.link}] to #{webp_path}" }
  ensure
    self.save!
  end

  def upload_to_r2!(force : Bool = false) : Nil
    return if !force && self.state > 4_i16

    success = R2Client.upload("covers/#{self.name}.webp", image_path(".webp"))

    self.state = success ? 6_i16 : 5_i16
    self.save!
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

  private def read_image_width(path : String) : Int32
    result = `identify -format '%w %h' "#{path}"`
    return 0 unless $?.success?
    result.split(' ', 2).first.to_i
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
      MIME.extensions(mime).first? || ".jpg"
    end
  end

  def valid?
    !self.ext.in?(".raw", ".html", ".ascii")
  end

  def cache!(force : Bool = false)
    return if self.state < 0_i16

    if self.state.in?(0_i16, 1_i16)
      download_image!(force: force)
      raise "fetching [#{self.link}] failed" unless self.state == 2_i16
    end

    raise "#{self.link} has invalid format #{self.ext}" unless self.valid?

    if self.state.in?(2_i16, 3_i16)
      convert_to_webp!(force: force)
      raise "can't convert #{self.link} to webp" unless self.state == 4_i16
    end

    # if state.in?(4_i16, 5_i16)
    #   upload_to_r2!(force: force)
    # end

    # raise "upload to Cloudflare R2 unsucessful" unless state == 6_i16
  end

  ####

  def self.gen_name(link : String)
    name = HashUtil.digest32(link, 8)
  end

  def self.init(link : String, name = "")
    name = gen_name(link) if name.blank?
    new({link: link, name: name}).tap(&.save!)
  end

  def self.load(link : String, name = "")
    find({link: link}) || init(link, name)
  end
end
