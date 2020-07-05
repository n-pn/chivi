require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

class HttpClient
  attr_reader :proxies

  PROXY_DIR = "var/appcv/.cache/yousuu/proxies"

  def initialize(load_proxy = false, debug_mode = false)
    @debug_mode = debug_mode
    @proxy_file = "#{PROXY_DIR}/working/#{Time.new.to_i / (3600 * 6)}.txt"

    @proxies = read_proxy_file(@proxy_file)
    load_previous_working_proxies if @proxies.size < 200
    load_initial_proxies if proxies.size < 200 || load_proxy
    puts "- <load_proxy> total proxies: #{@proxies.size.to_s.yellow} entries."
  end

  def load_previous_working_proxies
    files = Dir.glob("#{PROXY_DIR}/working/*.txt").sort_by do |file|
      File.basename(file, ".txt").to_i
    end

    files.pop if files[-1] == @proxy_file
    return if files.empty?

    file = files[-1]
    @proxies.concat(read_proxy_file(file)).uniq!
  end

  def load_initial_proxies
    Dir.glob("#{PROXY_DIR}/*.txt").each do |file|
      @proxies.concat(read_proxy_file(file)).uniq!
    end
  end

  def save_working_proxy(proxy)
    @proxies << proxy
    File.open(@proxy_file, "a") { |f| f.puts proxy }
  end

  private def read_proxy_file(file)
    return [] unless File.exists?(file)
    puts "- <load_proxy> [#{file.yellow}] loaded."
    File.read(file).split("\n").map(&:strip).reject(&:empty?).uniq
  end

  USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"

  def get!(url, file)
    return :no_more_proxy unless proxy = @proxies.pop
    puts "- GET: <#{url.blue}> using proxy [#{proxy.blue}]" if @debug_mode

    body = URI.open(url, proxy: "http://#{proxy}", read_timeout: 15, "User-Agent" => USER_AGENT) { |f| f.read }

    unless valid_response?(body)
      puts "- proxy [#{proxy.red}] not working, #{err.red}" if @debug_mode
      return :proxy_error
    end

    puts "- proxy [#{proxy.green}] worked!" if @debug_mode
    save_working_proxy(proxy)
    File.write(file, body)

    :success
  rescue => err
    puts "- ERROR: #{err.message.red}" if @debug_mode
    :proxy_error
  end

  def valid_response?(body)
    return true if body.include?("success")
    body.include?("未找到该图书")
  end
end
