require "log"
require "colorize"

class ProxyClient
  Log = ::Log.for("crawler")
  ::Log.setup_from_env(default_level: :error)

  class Proxy
    getter host : String, ok : Int32, ng : Int32

    def initialize(@host, @ok = 0, @ng = 0)
    end

    def count_ok!
      @ok += 1
      @ng = 0

      self
    end

    def count_ng!
      @ng += 1

      self
    end

    def already_ng?
      @ng > 2
    end
  end

  DIR = "var/proxy/.works"
  Dir.mkdir_p(DIR)

  getter proxies = [] of Proxy
  delegate size, to: @proxies
  delegate empty?, to: @proxies

  def initialize(reinit_proxies = false, limit = 200)
    fname = Time.utc.to_unix // (3600 * 12)
    @fpath = "#{DIR}/#{fname}.txt"

    files = Dir.glob("#{DIR}/*.txt")
    files.sort_by! { |f| File.basename(f, ".txt").to_i.- }

    files.first(4).each { |file| load_proxies(file) }
    @proxies.uniq!(&.host)

    if reinit_proxies || @proxies.size < limit
      Dir.glob("#{DIR}/../*.txt").each { |file| load_proxies(file) }
      @proxies.uniq!(&.host)
    end

    if @proxies.empty?
      Log.error { "No proxy loaded, aborting!".colorize.red }
      exit 1
    end

    @proxies.shuffle!
  end

  private def load_proxies(file : String) : Nil
    File.each_line(file) do |line|
      @proxies << Proxy.new(line) if line =~ /^\d+\.\d+\.\d+\.\d+:\d+$/
    end
  end

  def fetch!(link : String, label = "-/-") : String?
    unless proxy = @proxies.pop?
      Log.info { "Out of proxy, aborting!".colorize.red }
      exit 0
    end

    body = `curl -f -s -L -x #{proxy.host} -m 20 "#{link}"`

    if !$?.success? || body.empty? || body == "请稍后访问"
      Log.info { "- <#{label}> failed, remain proxies: #{@proxies.size}".colorize.yellow }
      add_proxy(proxy.count_ng!) unless proxy.already_ng?
      return nil
    end

    Log.info { "- <#{label}> successed.".colorize.green }
    File.open(@fpath, "a", &.puts(proxy.host))

    add_proxy(proxy.count_ok!)
    body
  end

  private def add_proxy(proxy : Proxy) : Nil
    (proxy.ok < 70 || @proxies.empty?) ? @proxies.push(proxy) : @proxies.unshift(proxy)
  end
end
