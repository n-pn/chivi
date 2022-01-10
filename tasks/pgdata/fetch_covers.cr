require "mime"
require "tabkv"
require "file_utils"
require "http/client"
require "colorize"

module CV::FetchCovers
  extend self

  INP = "var/nvinfos/autos"
  OUT = "var/nvinfos/_imgs"

  def fetch_yousuu(redo = false)
    input = Dir.glob("#{INP}/yousuu/covers/*.tsv").map do |file|
      basename = File.basename(file, ".tsv")
      {file, basename.split("-")[-1]}
    end

    input.sort_by! { |x| x[-1].to_i.- }

    input.each_with_index do |(file, dir), i|
      out_dir = "#{OUT}/yousuu/#{dir}"
      FileUtils.mkdir_p(out_dir)
      fetch_batch!("yousuu", file, out_dir, i * 1000, redo: redo)
    end
  end

  def fetch_batch!(sname : String, map_file : String, out_dir : String, offset = 0, redo = false)
    inp_map = Tabkv.new(map_file)
    out_map = Tabkv.new(map_file.sub(".tsv", ".tab"))

    queue = inp_map.data.compact_map do |snvid, value|
      if !redo && (result = out_map.get(snvid))
        next if make_webp(sname, snvid, "#{out_dir}/#{result[1]}")
      end

      link = value[0]
      next if link.empty? && !link.starts_with?("http")
      {snvid, link}
    end

    q_size = queue.size
    w_size = q_size > 12 ? 12 : q_size

    workers = Channel(Tuple(String, String, Int32)).new(w_size)
    results = Channel(Tuple(String, String, Int64)).new(q_size)

    spawn do
      queue.each_with_index(1) do |(snvid, link), idx|
        workers.send({snvid, link, idx + offset})
      end
    end

    finished = false

    w_size.times do
      spawn do
        loop do
          snvid, link, idx = workers.receive
          size, file = save_image(link, snvid, out_dir)
          puts "- <#{idx}: #{snvid}> #{link}".colorize.cyan
          results.send({snvid, file, size})
          break if finished
        end
      end
    end

    q_size.times do |idx|
      select
      when result = results.receive
        snvid, file, size = result

        out_map.set!(snvid, [size.to_s, File.basename(file)])
        out_map.save! if idx % 10 == 0
      when timeout(10.seconds)
        next
      end
    end

    finished = true
    out_map.save!
  end

  KNOWN_EXTS = {".jpg", ".raw", ".png", ".gif", ".webp", ".html"}

  def save_image(link : String, name : String, out_dir : String)
    out_file = File.join(out_dir, name + ".jpg")

    HTTP::Client.get(link) do |res|
      ext = map_extension(res.content_type)

      unless KNOWN_EXTS.includes?(ext)
        puts [res.content_type, link, out_file].colorize.red
      end

      out_file = out_file.sub(".jpg", ext)
      File.write(out_file, res.body_io)
    end

    {File.size(out_file), out_file}
  rescue
    {0_i64, ""}
  end

  def map_extension(mime : String?)
    case mime
    when .nil?        then ".raw"
    when "image/jpeg" then ".jpg"
    when "image/png"  then ".png"
    when "image/gif"  then ".gif"
    when "image/webp" then ".webp"
    when "text/html"  then ".html"
    else
      exts = MIME.extensions(mime)
      return ".raw" if exts.empty?

      puts exts
      exts.first
    end
  end

  OUT_DIR = "priv/static/covers"

  def make_webp(sname : String, snvid : String, inp_file : String) : Bool
    out_file = "#{OUT_DIR}/#{sname}-#{snvid}.webp"
    return true if File.exists?(out_file)

    puts "- #{inp_file} => #{File.basename(out_file)}".colorize.yellow

    case File.extname(inp_file)
    when ".xml", ".html", ".raw"
      puts "  Invalid format, skipping"
      return false
    when ".gif"
      gif_to_webp(inp_file, out_file)
    else
      width = read_image_width(inp_file)
      to_webp(inp_file, out_file, width: width > 360 ? 360 : width)
    end

    File.exists?(out_file)
  end

  private def gif_to_webp(inp_file, out_file)
    `gif2webp -quiet "#{inp_file}" -o "#{out_file}"`
  end

  private def to_webp(inp_file : String, out_file : String, width = 360)
    if width > 360
      `cwebp -quiet -q 100 -resize #{width} 0 -mt "#{inp_file}" -o "#{out_file}"`
    else
      `cwebp -quiet -q 100 -mt "#{inp_file}" -o "#{out_file}"`
    end

    return if File.exists?(out_file)
    `convert #{inp_file} -quality 50 -define webp:lossless=true -resize "#{width}x>" #{out_file}`
  end

  private def read_image_width(image_path : String)
    `identify -format '%w %h' "#{image_path}"`.split(" ").first.to_i? || 0
  rescue
    0
  end
end

CV::FetchCovers.fetch_yousuu(redo: false)

# def fix_image_ext(inp_file : String)
#   return if File.size(inp_file) == 0

#   return unless type = image_type(inp_file)
#   return if type == "jpeg"

#   out_file = inp_file.sub(".jpg", image_ext(type))
#   File.copy(inp_file, out_file)
# rescue err
#   puts err
# end

# private def image_type(file : String)
#   `file -b "#{file}"`.split(" ").first?.try(&.downcase)
# end

# private def image_ext(type : String)
#   type == "gzip" ? ".jpg.gz" : ".#{type}"
# end
