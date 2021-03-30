require "colorize"
require "file_utils"

class Client
  class Proxy
    property host, succ, fail

    def initialize(@host : String, @succ = 0, @fail = 0)
    end
  end

  PROXY_DIR = "_db/yousuu/_proxy"
  WORKS_DIR = "#{PROXY_DIR}/.works"
  ::FileUtils.mkdir_p(WORKS_DIR)

  getter proxies = [] of Proxy

  def initialize(regen = false)
    time_slice = Time.utc.to_unix // 3600 * 12
    @proxy_file = "#{WORKS_DIR}/#{time_slice}.txt"

    load_proxies(@proxy_file)

    if @proxies.size < 200 || regen
      previous_proxy_file.try { |file| load_proxies(file) }
      Dir.glob("#{PROXY_DIR}/*.txt").each { |file| load_proxies(file) }
    end
  end

  delegate size, to: @proxies

  private def load_proxies(file : String) : Nil
    return unless File.exists?(file)

    lines = File.read_lines(file).map(&.strip).uniq
    input = lines.select { |line| line =~ /^\d+\.\d+\.\d+\.\d+:\d+$/ }
    puts "- <proxies> [#{file}] loaded, entries: #{input.size}".colorize.yellow

    input.each { |proxy| @proxies << Proxy.new(proxy) }
    @proxies.uniq!
  end

  private def previous_proxy_file : String?
    files = Dir.glob("#{WORKS_DIR}/*.txt")
    files.sort_by! { |file| File.basename(file, ".txt").to_i? || 0 }

    return unless last = files.last?
    last == @proxy_file ? files[-2]? : last
  end

  def save!(link : String, file : String)
    return :no_proxy unless proxy = @proxies.pop

    body = `curl -s -L -x #{proxy.host} -m 30 "#{link}"`
    case body
    when .starts_with?("{\"success"), .includes?("未找到该图书")
      File.open(@proxy_file, "a", &.puts(proxy.host))
      File.write(file, body)

      handle_succ(proxy)
      :ok
    else
      handle_fail(proxy)
      :err
    end
  end

  private def handle_succ(proxy : Proxy)
    proxy.succ += 1
    proxy.fail = 0
    add_proxy(proxy, append: proxy.succ < 50)
  end

  private def handle_fail(proxy : Proxy)
    proxy.fail += 1
    add_proxy(proxy, append: proxy.succ == 0) if proxy.fail < 3
  end

  def add_proxy(proxy : Proxy, append = true)
    append ? @proxies.push(proxy) : @proxies.unshift(proxy)
  end
end
