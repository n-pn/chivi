require "log"
require "colorize"
require "option_parser"
require "../src/_init/books/bcover"
require "../src/_init/books/book_info"

module CV
  extend self

  def single(link : String, name : String = "", force = false) : Nil
    raise "Empty link" if link.empty?

    cover = Bcover.init(link, name)
    if !force && cover.on_r2
      return puts "[#{cover.name}] uploaded, skipping!".colorize.cyan
    end

    if force || !cover.exists?
      raise "Dead site [#{link}]" if link =~ /bxwxorg|biqugee|jx_la|zhwenpg/

      raise "Fetch failed! for #{cover.link}" unless cover.fetch!(force: force)
      raise "Invalid format #{cover.format}" unless cover.valid?
      raise "Can't convert to webp" unless cover.to_webp!(force: force)
      cover.atomic_save!
    end

    raise "Upload to Cloudflare R2 unsucessful" unless cover.to_r2!
    puts "[#{cover.name}] saved and uploaded to cloudflare r2!".colorize.yellow
    cover.clean_save!
  end

  def batch(sname = "=base", force = false)
    files = Dir.glob("var/books/infos/#{sname}/*.tsv").shuffle

    q_size = files.size
    w_size = 8

    workers = Channel(String).new(q_size)
    results = Channel(Nil).new(w_size)

    spawn do
      files.each { |file| workers.send(file) }
    end

    w_size.times do
      spawn do
        loop do
          info = BookInfo.new(workers.receive)
          single(info.bcover, force: force) unless info.bcover.empty?
        rescue err
          Log.error(exception: err) { err.message.colorize.red }
        ensure
          results.send(nil)
        end
      end
    end

    q_size.times { results.receive }
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
    puts err.message.colorize.red
    exit 1
  end

  run!(ARGV)
end
