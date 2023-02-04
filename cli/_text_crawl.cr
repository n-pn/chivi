require "log"
require "colorize"
require "http/client"
require "compress/zip"
require "option_parser"

record Entry,
  link : String,
  file : String,
  encoding : String do
  def initialize(args : Array(String))
    @link = args[0]
    @file = args[1]? || File.basename(@link)
    @encoding = args[2]? || "UTF-8"
  end
end

class TextCrawl
  @entries : Array(Entry)
  @out_dir : String

  def initialize(@entries, @out_dir, skip_existing = true)
    if skip_existing
      @entries.reject! do |entry|
        file_path = File.join(@out_dir, entry.file)
        File.exists?(file_path + ".gz")
      end
    end

    puts "To be crawled: #{@entries.size}, redo: #{!skip_existing}"
    Dir.mkdir_p(@out_dir)
  end

  def crawl(threads = 6) : Nil
    workers = Channel(Entry).new(@entries.size)
    results = Channel(Nil).new(threads)

    threads.times do
      spawn do
        loop do
          fetch(workers.receive)
        rescue err
          Log.error(exception: err) { err.message.colorize.red }
        ensure
          results.send(nil)
        end
      end
    end

    @entries.each { |entry| workers.send(entry) }
    @entries.size.times { results.receive }
  end

  def fetch(entry : Entry)
    puts " - GET: #{entry.link}".colorize.cyan

    out_data = HTTP::Client.get(entry.link) do |res|
      res.body_io.set_encoding(entry.encoding, invalid: :skip)
      body = res.body_io.gets_to_end.lstrip

      if entry.encoding != "UTF-8" && entry.file.ends_with?("html")
        body = body.sub(/charset="?#{entry.encoding}"?/i, %{charset="utf-8"})
      end

      body
    end

    out_path = File.join(@out_dir, entry.file)
    Dir.mkdir_p(File.dirname(out_path))

    File.open(out_path + ".gz", "w") do |io|
      Compress::Gzip::Writer.open(io, &.print(out_data))
    end
  end

  # class methods

  def self.run!(argv = ARGV)
    entries = [] of Entry
    out_dir = "var/texts/.cache"

    skip = false
    conn = 6

    OptionParser.parse(argv) do |parser|
      parser.on("--skip", "skip downloaded entries") { skip = true }
      parser.on("-t THREADS", "concurrent") { |c| conn = c.to_i }
      parser.on("-o OUT_DIR", "output folder") { |f| out_dir = f }

      parser.unknown_args do |args|
        args.each do |path|
          File.each_line(path) do |line|
            entries << Entry.new(line.split('\t')) unless line.empty?
          end
        end
      end
    end

    crawler = new(entries, out_dir, skip_existing: skip)
    crawler.crawl(conn)
  end

  run!(ARGV)
end
