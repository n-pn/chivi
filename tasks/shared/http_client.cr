require "log"
require "colorize"

class CV::HttpClient
  class Proxy
    property host, succ, fail

    def initialize(@host : String, @succ = 0, @fail = 0)
    end
  end

  PROXY_DIR = "_db/yousuu/_proxy"
  WORKS_DIR = "#{PROXY_DIR}/.works"
  Dir.mkdir_p(WORKS_DIR)

  getter proxies = [] of Proxy

  def initialize(regen = false, limit = 200)
    time_slice = Time.utc.to_unix // (3600 * 12)
    @proxy_file = "#{WORKS_DIR}/#{time_slice}.txt"

    files = Dir.glob("#{WORKS_DIR}/*.txt")

    files.sort_by! { |file| File.basename(file, ".txt").to_i }
    files.reverse_each do |file|
      load_proxies(file)
      break if @proxies.size > limit
    end

    if regen || @proxies.size < limit
      Dir.glob("#{PROXY_DIR}/*.txt").each { |file| load_proxies(file) }
    end
  end

  delegate size, to: @proxies

  private def load_proxies(file : String) : Nil
    lines = File.read_lines(file).map(&.strip).uniq
    input = lines.select { |line| line =~ /^\d+\.\d+\.\d+\.\d+:\d+$/ }
    Log.info { "[#{file.colorize.yellow}] loaded, entries: #{input.size.colorize.yellow}" }

    input.each { |proxy| @proxies << Proxy.new(proxy) }
    @proxies.uniq!.shuffle!
  end

  def save!(link : String, file : String, label : String) : Bool
    unless proxy = @proxies.pop?
      Log.info { " - Out of proxy, aborting!".colorize.red }
      exit(0)
    end

    body = `curl -s -L -x #{proxy.host} -m 30 "#{link}"`

    case body
    when .starts_with?("{\"success"), .includes?("未找到该图书")
      Dir.mkdir_p(File.dirname(file))
      File.write(file, body)
      Log.info { "- #{label} saved".colorize.green }

      File.open(@proxy_file, "a", &.puts(proxy.host)) if proxy.succ == 0

      proxy.succ += 1
      proxy.fail = 0
      add_proxy(proxy, append: proxy.succ < 50)

      true
    else
      Log.info { "- #{label} failed, remain proxies: #{@proxies.size}".colorize.yellow }
      proxy.fail += 1
      add_proxy(proxy, append: proxy.succ == 0) if proxy.fail < 4

      false
    end
  end

  def add_proxy(proxy : Proxy, append = true)
    append || @proxies.empty? ? @proxies.push(proxy) : @proxies.unshift(proxy)
  end

  def no_proxy?
    @proxies.empty?
  end
end
