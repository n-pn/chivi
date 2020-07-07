require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

class HttpClient
  attr_reader :proxies

  PROXY_DIR = "var/.book_cache/yousuu/proxies"

  def initialize(load_proxy = false, debug_mode = false)
    @debug_mode = debug_mode
    @proxy_file = "#{PROXY_DIR}/working/#{Time.new.to_i / (3600 * 6)}.txt"

    proxies = read_proxy_file(@proxy_file)
    load_previous_working_proxies(proxies) if proxies.size < 200
    load_bootstrap_proxies(proxies) if proxies.size < 200 || load_proxy
    puts "- <load_proxy> total proxies: #{proxies.size.to_s.yellow} entries."

    @proxies = proxies.map { |x| [x, 0, 0] }
  end

  def load_previous_working_proxies(proxies)
    files = Dir.glob("#{PROXY_DIR}/working/*.txt").sort_by do |file|
      File.basename(file, ".txt").to_i
    end

    files.pop if files[-1] == @proxy_file
    return if files.empty?

    file = files[-1]
    proxies.concat(read_proxy_file(file)).uniq!
  end

  def load_bootstrap_proxies(proxies)
    Dir.glob("#{PROXY_DIR}/*.txt").each do |file|
      proxies.concat(read_proxy_file(file)).uniq!
    end
  end

  private def read_proxy_file(file)
    return [] unless File.exists?(file)
    puts "- <load_proxy> [#{file.yellow}] loaded."
    File.read(file).split("\n").map(&:strip).reject(&:empty?).uniq
  end

  USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"

  def get!(url, file)
    return :no_more_proxy unless proxy = @proxies.pop

    begin
      puts "- GET: <#{url.blue}> using proxy [#{proxy[0].blue}]" if @debug_mode

      body = URI.open(url, proxy: "http://#{proxy[0]}", read_timeout: 15, "User-Agent" => USER_AGENT) { |f| f.read }

      unless valid_response?(body)
        puts "- proxy [#{proxy[0].red}] not working, #{err.red}" if @debug_mode
        return :proxy_error
      end

      puts "- proxy [#{proxy[0].green}] worked!" if @debug_mode
      handle_working_proxy(proxy)
      File.write(file, body)

      :success
    rescue => err
      puts "- ERROR: #{err.message.red}" if @debug_mode
      handle_failed_proxy(proxy)

      :proxy_error
    end
  end

  def valid_response?(body)
    return true if body.include?("success")
    body.include?("未找到该图书")
  end

  def handle_working_proxy(proxy)
    File.open(@proxy_file, "a") { |f| f.puts proxy[0] }

    proxy[1] += 1
    proxy[2] -= 1 if proxy[2] > 0

    if proxy[1] < 50
      @proxies.push(proxy)
    else
      @proxies.unshift(proxy)
    end
  end

  def handle_failed_proxy(proxy)
    return if proxy[2] > 2

    proxy[2] += 1
    if proxy[1] > 0
      @proxies.unshift(proxy)
    else
      @proxies.push(proxy)
    end
  end
end
