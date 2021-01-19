require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

class HttpClient
  attr_reader :proxies

  PROXY_DIR = "_db/_proxy"
  INTERVAL = 3600 * 10

  def initialize(load_proxy = false, debug_mode = false)
    @debug_mode = debug_mode
    @proxy_file = "#{PROXY_DIR}/.works/#{Time.new.to_i / INTERVAL}.txt"

    proxies = read_proxy_file(@proxy_file)
    load_previous_working_proxies(proxies) if proxies.size < 200
    load_bootstrap_proxies(proxies) if proxies.size < 200 || load_proxy
    puts "- <load_proxy> total proxies: #{proxies.size.to_s.yellow} entries."

    @proxies = proxies.shuffle.map { |x| [x, 0, 0] }
  end

  def load_previous_working_proxies(proxies)
    files = Dir.glob("#{PROXY_DIR}/.works/*.txt").sort_by do |file|
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

  def read_proxy_file(file)
    ret = []
    return ret unless File.exists?(file)

    File.read(file).split("\n").each do |line|
      line.chomp!
      ret << line if line =~ /^\d+\.\d+\.\d+\.\d+:\d+$/
    end

    puts "- <load_proxy> [#{file.yellow}] loaded."

    ret
  end

  USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"

  def get!(url, file)
    return :no_more_proxy unless proxy = @proxies.pop
    puts "- GET: <#{url.blue}> using proxy [#{proxy[0].blue}]" if @debug_mode

    begin
      body = URI.open(url, proxy: "http://#{proxy[0]}", read_timeout: 20, "User-Agent" => USER_AGENT) { |f| f.read }

      unless valid_response?(body)
        if @debug_mode
          puts "- proxy [#{proxy[0].red}] not working"
          puts body
        end

        return :proxy_error
      end

      puts "- proxy [#{proxy[0].green}] worked!" if @debug_mode
      handle_working_proxy(proxy)
      File.write(file, body)

      :success
    rescue Exception => err
      handle_failed_proxy(proxy, err.message)
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

  def handle_failed_proxy(proxy, message)
    return if message.start_with?('400 "Bad Request"')
    return if message.start_with?('501 "Tor is not an HTTP Proxy"')
    return if message.start_with?('Failed to open TCP connection')

    puts "- ERROR: #{message.red}" if @debug_mode
    return if proxy[2] >= 2

    proxy[2] += 1
    if proxy[1] > 0
      @proxies.unshift(proxy)
    else
      @proxies.push(proxy)
    end
  end
end
