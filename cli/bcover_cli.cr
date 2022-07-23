require "log"
require "colorize"
require "option_parser"
require "../src/appcv/inits/bcover"
require "../src/_init/books/book_info"

module CV
  extend self

  def single(link : String, name : String = "", force = false) : Nil
    raise "Empty link" if link.empty?

    cover = Bcover.init(link, name)
    return puts "Uploaded, skipping!" if !force && cover.on_r2

    if force || !cover.exists?
      raise "Fetch failed! for #{cover.link}" unless cover.fetch!(force: force)
      raise "Invalid format #{cover.format}" unless cover.valid?
      raise "Can't convert to webp" unless cover.to_webp!(force: force)
    end

    cover.atomic_save!

    raise "Upload to Cloudflare R2 unsucessful" unless cover.to_r2!
    puts "[#{cover.name}] saved and uploaded to cloudflare r2!"
    cover.clean_save!
  end

  def batch(sname = "=base", force = false)
    files = Dir.glob("var/books/infos/#{sname}/*.tsv")

    files.each do |file|
      info = BookInfo.new(file)
      single(info.bcover, force: force) unless info.bcover.empty?
    rescue err
      puts err
    end
  end

  def run!(argv = ARGV)
    mode = 0
    force = false

    image_link = ""
    image_name = ""

    seed_name = "=base"

    OptionParser.parse(argv) do |parser|
      parser.on("-f", "Force redo") { force = true }

      parser.on("single", "Work with a single book cover") do
        mode = 1
        parser.on("-i LINK", "image link") { |i| image_link = i }
        parser.on("-n NAME", "image name") { |i| image_name = i }
      end

      parser.on("batch", "Fetch all covers") do
        mode = 2
        parser.on("-s SEED", "seed folder") { |s| seed_name = s }
      end
    end

    case mode
    when 1 then single(image_link, image_name, force)
    when 2 then batch(seed_name, force)
    else        raise "Unsupported mode"
    end
  rescue err
    puts err.message
    exit 1
  end

  run!(ARGV)
end
