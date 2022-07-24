require "log"
require "file_utils"
require "../shared/bootstrap"

module CV::FixCovers
  extend self

  INP = "_db/bcover"
  OUT = "priv/static/covers"

  def cover_path(sname : String, snvid : String, togen = "")
    prefix = snvid.to_i?.try(&.// 1000) || -1

    {"png", "gif", "webp", "bmp", "jpg"}.each do |ext|
      file = "#{INP}/#{sname}/#{prefix}/#{snvid}.#{ext}"
      return file if File.exists?(file) || ext == togen
    end
  end

  def copy_file(sname : String, snvid : String, slink : String, nodl = false) : {String, Int32}?
    out_file = UkeyUtil.digest32(slink) + ".webp"
    out_path = File.join(OUT, out_file)

    if File.exists?(out_path)
      return {out_file, HttpUtil.image_width(out_path) || 9999}
    end

    unless inp_path = cover_path(sname, snvid)
      return if nodl || slink.empty? || SnameMap.map_type(sname) < 3
      inp_path = cover_path(sname, snvid, togen: "jpg").not_nil!

      Log.info { "Fetching [#{sname}/#{snvid}]: #{slink}".colorize.cyan }
      return unless inp_path = HttpUtil.fetch_image(slink, inp_path)
    end

    if inp_path.ends_with?(".gif")
      HttpUtil.gif_to_webp(inp_path, out_path)
      width = 9999
    elsif width = HttpUtil.image_width(inp_path, delete: true)
      HttpUtil.img_to_webp(inp_path, out_path, width)
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
