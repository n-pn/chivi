require "log"
require "colorize"
require "http/client"
require "compress/zip"
require "option_parser"

class Crawler
  record Entry,
    link : String,
    file : String,
    encoding : String,
    fix_charset : Bool do
    def initialize(args : Array(String))
      @link = args[0]
      @file = args[1]? || File.basename(@link)
      @encoding = args[2]? || "UTF-8"
      @fix_charset = @encoding != "UTF-8" && @file.ends_with?(".html")
    end
  end

  @entries : Array(Entry)
  @out_dir : String

  def initialize(@entries, @out_dir, @gzip = true, skip_existing = true)
    if skip_existing
      @entries.reject! do |entry|
        file_path = File.join(@out_dir, entry.file)
        file_path += ".gz" if gzip
        File.exists?(file_path)
      end
    end

    puts "To be crawled: #{@entries.size}, gzip: #{@gzip}, redo: #{!skip_existing}"
    Dir.mkdir_p(@out_dir)
  end

  def crawl(conn = 6) : Nil
    if @entries.size <= conn
      @entries.each { |entry| fetch(entry) }
      return
    end

    queue = Channel(Entry).new(@entries.size)
    catch = Channel(Nil).new(conn)

    spawn do
      @entries.each { |entry| queue.send(entry) }
    end

    conn.times do
      spawn do
        loop do
          fetch(queue.receive)
        rescue err
          Log.error(exception: err) { err.message.colorize.red }
        ensure
          catch.send(nil)
        end
      end
    end

    @entries.size.times { catch.receive }
  end

  def fetch(entry : Entry)
    puts " - GET: #{entry.link}".colorize.cyan

    out_data = HTTP::Client.get(entry.link) do |res|
      res.body_io.set_encoding(entry.encoding, invalid: :skip)
      body = res.body_io.gets_to_end.lstrip
      break body unless entry.fix_charset
      body.sub(/charset=\"?#{entry.encoding}\"?/i, %{charset="utf-8"})
    end

    out_path = File.join(@out_dir, entry.file)

    if @gzip
      File.open(out_path + ".gz", "w") do |io|
        Compress::Gzip::Writer.open(io, &.print(out_data))
      end
    else
      File.write(out_path, out_data)
    end
  end

  # class methods

  def self.run!(argv = ARGV)
    entries = [] of Entry
    out_dir = ".cache"

    skip = false
    gzip = false
    conn = 6

    OptionParser.parse(argv) do |parser|
      parser.on("--skip", "skip downloaded entries") { skip = true }
      parser.on("--gzip", "save content as gzip") { gzip = true }
      parser.on("-c CONCURRENT", "concurrent") { |c| conn = c.to_i }
      parser.on("-o OUT_DIR", "output folder") { |f| out_dir = f }

      parser.on("-i QUEUE_FILE", "queue file") do |file|
        File.each_line(file) do |line|
          entries << Entry.new(line.split('\t')) unless line.empty?
        rescue err
          puts line, err
        end

        out_dir = file.sub(File.extname(file), "") if out_dir == ".cache"
      end

      parser.unknown_args { |args| entries << Entry.new(args) unless args.empty? }
    end

    if entries.empty?
      while line = STDIN.gets
        entries << Entry.new(line.split('\t')) unless line.empty?
      end
    end

    crawler = new(entries, out_dir, gzip: gzip, skip_existing: skip)
    crawler.crawl(conn)
  end

  run!(ARGV)
end
