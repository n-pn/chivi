require "log"
require "file_utils"
require "../shared/bootstrap"

module CV::FixCovers
  extend self

  INP = "_db/bcover"
  OUT = "priv/static/covers"

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

  def cover_path(sname : String, snvid : String, togen = "")
    prefix = snvid.to_i?.try(&.// 1000) || -1

    {"png", "gif", "webp", "bmp", "jpg"}.each do |ext|
      file = "#{INP}/#{sname}/#{prefix}/#{snvid}.#{ext}"
      return file if File.exists?(file) || ext == togen
    end
  end

  def image_width(file : String, delete = false) : Int32?
    return unless File.exists?(file)
    `identify -format '%w %h' "#{file}"`.split(" ").first.to_i?
  rescue err
    Log.error { [file, err].colorize.red }
    File.delete(file) if delete
  end

  KNOWN_EXTS = {".jpg", ".raw", ".png", ".gif", ".webp", ".html", ".xml"}

  def fetch_image(link : String, out_file : String) : String?
    HTTP::Client.get(link) do |res|
      ext = map_extension(res.content_type)

      unless KNOWN_EXTS.includes?(ext)
        Log.error { [res.content_type, link, out_file].colorize.red }
      end

      out_file = out_file.sub(".jpg", ext)

      Dir.mkdir_p(File.dirname(out_file))
      File.write(out_file, res.body_io)
    end

    Log.info { "[#{link}] saved to [#{out_file}]".colorize.yellow }
    out_file
  rescue err
    Log.error { err.colorize.red }
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
      exts.empty? ? ".raw" : exts.first
    end
  end

  def copy_file(sname : String, snvid : String, slink : String, nodl = false) : {String, Int32}?
    out_file = UkeyUtil.digest32(slink) + ".webp"
    out_path = File.join(OUT, out_file)

    if File.exists?(out_path)
      return {out_file, image_width(out_path) || 9999}
    end

    unless inp_path = cover_path(sname, snvid)
      return if nodl || slink.empty? || SnameMap.map_type(sname) < 3
      inp_path = cover_path(sname, snvid, togen: "jpg").not_nil!

      Log.info { "Fetching [#{sname}/#{snvid}]: #{slink}".colorize.cyan }
      return unless inp_path = fetch_image(slink, inp_path)
    end

    if inp_path.ends_with?(".gif")
      gif_to_webp(inp_path, out_path)
      width = 9999
    elsif width = image_width(inp_path, delete: true)
      img_to_webp(inp_path, out_path, width)
    end

    return unless width && File.exists?(out_path)
    {out_file, width}
  end

  def fix_cover(nvinfo : Nvinfo, redo = false, nodl = false)
    unless nvinfo.bcover.empty?
      return if !redo && File.exists?("#{OUT}/#{nvinfo.bcover}")
    end

    covers = [] of {String, String, String}

    if ysbook = nvinfo.ysbook
      covers << {"yousuu", ysbook.id.to_s, ysbook.bcover}
    end

    nvinfo.nvseeds.each do |nvseed|
      covers << {nvseed.sname, nvseed.snvid, nvseed.bcover}
    end

    max_width = 0

    covers.each do |sname, snvid, scover|
      next unless data = copy_file(sname, snvid, scover, nodl: nodl)

      bcover, width = data
      next unless width > max_width

      nvinfo.update({bcover: bcover, scover: scover})

      return if width >= 150
      max_width = width
    end

    nvinfo.update({bcover: ""}) if max_width == 0
  end

  def run!(clean = false)
    redo = ARGV.includes?("--redo")
    nodl = ARGV.includes?("--nodl")

    input = Nvinfo.query.order_by(id: :desc).to_a

    q_size = input.size
    w_size = q_size > 8 ? 8 : q_size

    workers = Channel(Nvinfo).new(w_size)
    results = Channel(Nvinfo).new(q_size)

    spawn do
      input.each do |nvinfo|
        workers.send(nvinfo)
      end
    end

    w_size.times do
      spawn do
        loop do
          nvinfo = workers.receive
          fix_cover(nvinfo, redo: redo, nodl: nodl)
          results.send(nvinfo)
        end
      end
    end

    q_size.times do |idx|
      select
      when nvinfo = results.receive
        label = "<#{idx}/#{input.size}> : #{nvinfo.bslug} =>"

        if nvinfo.bcover.empty?
          Log.error { "#{label} #{nvinfo.scover}".colorize.red }
        else
          Log.info { "#{label} #{nvinfo.bcover}".colorize.green }
        end
      when timeout(30.seconds)
        Log.info { "<#{idx}> Timeout!!".colorize.red }
        next
      end
    end

    return unless ARGV.includes?("--clean")
    to_delete = Dir.children(OUT) - input.map(&.bcover)
    to_delete.each { |file| File.delete("#{OUT}/#{file}") }
  end

  run!
end
