require "log"
require "colorize"
require "http/client"

class Crawler
  record Entry, link : String, file : String do
    def initialize(args : Array(String))
      @link = args[0]

      chap_file = args[1]? || File.basename(@link)
      @file = chap_file.sub(".html", ".meta")
    end
  end

  @entries : Array(Entry)
  @out_dir : String

  def initialize(@entries, @out_dir)
    @entries.reject! do |entry|
      File.exists?(File.join(@out_dir, entry.file))
    end

    puts "Crawling #{@out_dir}: #{@entries.size} tokens".colorize.yellow
    Dir.mkdir_p(@out_dir)
  end

  def crawl(conn = 3) : Nil
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
    headers = HTTP::Headers{
      "Referer"          => entry.link,
      "Content-Type"     => "application/x-www-form-urlencoded",
      "X-Requested-With" => "XMLHttpRequest",
      "Cookie"           => "PHPSESSID=48grk8h3bi58q13rhbjp1kaa73",
    }

    base_name = File.basename(entry.file, ".meta")
    json_link = File.dirname(entry.link) + "/r#{base_name}.json"
    puts " - GET: #{json_link}".colorize.blue

    HTTP::Client.get(json_link, headers: headers) do |res|
      token = res.headers["token"]
      File.write(File.join(@out_dir, entry.file), token)
    end
  end

  # class methods

  def self.run!(inp_file : String)
    entries = [] of Entry
    out_dir = inp_file.sub(".tsv", "")

    File.each_line(inp_file) do |line|
      entries << Entry.new(line.split('\t')) unless line.empty?
    end

    crawler = new(entries, out_dir)
    crawler.crawl(3)
  end

  run!(ARGV[0])
end
