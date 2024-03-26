require "http/client"
require "crorm"

# require "../_util/r2_client"
require "../../_util/hash_util"

class WN::Bcover
  class_getter db_path = "/srv/chivi/zroot/global/bcovers.db3"

  class_getter init_sql = <<-SQL
    create table bcovers(
      link varchar not null primary key,

      name varchar not null,
      ext varchar not null default '.jpg',

      width integer default 0,
      mtime integer default 0,

      _flag integer default 0
    );
    SQL

  include Crorm::Model
  schema "bcovers", :sqlite

  def self.load(link : String, name : String = "") : self
    self.get_by_pkey(link) || new(link, name)
  end

  DIR = "/srv/chivi/files/covers"
  Dir.mkdir_p(DIR)

  MAX_WIDTH = 300

  field link : String
  field name : String = ""
  field ext : String = ".jpg" # original image extension

  field width : Int32 = 0 # image width
  field mtime : Int64 = Time.utc.to_unix

  # _flag
  # - 0: initialized

  # - 1: downloaded but failed
  # - 2: downloaded

  # - 3: converted to webp failed
  # - 4: converted to webp

  # - 5: uploaded to cloudflare r2 but failed
  # - 6: uploaded to cloudflare r2

  field _flag : Int32 = 0

  def initialize(@link : String, @name = "")
    @name = HashUtil.digest32(link, 8) if name.blank?
  end

  def dead_link?
    @link =~ /bxwxorg|biqugee|jx_la|zhwenpg/
  end

  def image_path(ext : String = self.ext)
    File.join(DIR, "#{@name}#{ext}")
  end

  def download_image!(force = false) : Nil
    return if !force && _flag == 1

    puts "- Fetching: #{@link}"
    path = self.image_path(self.ext)

    HTTP::Client.get(self.link) do |res|
      ext = map_extension(res.content_type)
      path = path.sub(self.ext, ext)
      @ext = ext

      if res.headers["Content-Encoding"]? == "gzip"
        gz_path = path + ".gz"
        File.write(gz_path, res.body_io)
        `gzip -d #{gz_path}`
      else
        File.write(path, res.body_io)
      end
    end

    @_flag = File.exists?(path) ? 2 : 1
    self.save!
  end

  def convert_to_webp!(force = false) : Nil
    return if !force && @_flag != 4

    puts "- Save [#{@link}] as webp"

    orig_path = self.image_path(self.ext)
    webp_path = self.image_path(".webp")

    @width = read_image_width(orig_path)
    resize = self.width > MAX_WIDTH

    if self.ext == ".gif"
      success = gif_to_webp(orig_path, webp_path, resize: resize)
    else
      success = img_to_webp(orig_path, webp_path, resize: resize)
    end

    @_flag = success ? 4 : 3
  ensure
    self.save!
  end

  def upload_to_r2!(force : Bool = false) : Nil
    return if !force && _flag == 6

    success = R2Client.upload("covers/#{@name}.webp", image_path(".webp"))
    @_flag = success ? 6 : 5
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

  def do_tasks!(force : Bool = false)
    return if _flag < 0

    if _flag.in?(0, 1)
      download_image!(force: force)
      raise "fetching [#{@link}] failed" unless _flag == 2
    end

    raise "invalid format #{@ext}" unless self.valid?

    if _flag.in?(2, 3)
      convert_to_webp!(force: force)
      raise "can't convert to webp" unless _flag == 4
    end

    if _flag.in?(4, 5)
      upload_to_r2!(force: force)
    end

    raise "upload to Cloudflare R2 unsucessful" unless _flag == 6
  end
end
