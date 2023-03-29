require "log"
require "colorize"
require "option_parser"

require "../src/_data/wnovel/bcover"

def crawl_one(link : String, name : String = "", force = false) : Nil
  raise "Empty link" if link.empty?

  cover = CV::Bcover.load(link)
  cover.name = CV::Bcover.gen_name(link) if cover.name.blank?

  cover.cache!(force: force)
  Log.info { "[#{cover.name}] saved".colorize.yellow }
end

def crawl_all(links : Array(String), force = false)
  q_size = links.size
  w_size = 8

  workers = Channel(String).new(q_size)
  results = Channel(Nil).new(w_size)

  w_size.times do
    spawn do
      loop do
        link = workers.receive
        crawl_one(link, force: force) unless link.empty?
      rescue err
        Log.error(exception: err) { err.message.colorize.red }
      ensure
        results.send(nil)
      end
    end
  end

  links.each { |link| workers.send(link) }
  q_size.times { results.receive }
end

def run!(argv = ARGV)
  mode = 0
  force = false

  image_link = ""
  image_name = ""

  OptionParser.parse(argv) do |parser|
    parser.on("-f", "Force redo") { force = true }

    parser.on("one", "Work with a single book cover") do
      mode = 1
      parser.on("-i LINK", "image link") { |i| image_link = i }
      parser.on("-n NAME", "image name") { |i| image_name = i }
    end

    parser.on("all", "Fetch all covers") do
      mode = 2
    end
  end

  case mode
  when 1
    crawl_one(image_link, image_name, force: force)
  when 2
    links = CV::Bcover.query.where("state < 4").order_by(wn_id: :desc).map(&.link)
    links.reject!(&.=~ /bxwxorg|biqugee|jx.la|zhwenpg|shubaow/)

    crawl_all(links, force: force)
  else raise "Unsupported mode"
  end
rescue err
  puts err.message.colorize.red
  exit 1
end

run!(ARGV)
