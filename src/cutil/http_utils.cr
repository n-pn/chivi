require "colorize"
require "http/client"
require "compress/gzip"

# require "crest"

module CV::HttpUtils
  extend self

  TTL = Time.utc(2000, 1, 1)

  def load_html(link : String, file : String, ttl = TTL, encoding = "UTF-8", label = "1/1")
    unless html = read_html(file, ttl: ttl)
      html = get_html(link, encoding: encoding, label: label)
      save_html(file, html)
    end

    html
  end

  def read_html(file : String, ttl = TTL) : String?
    expiry = ttl.is_a?(Time) ? ttl : Time.utc - ttl
    return if staled?(file, expiry)

    return File.read(file) unless file.ends_with?(".gz")

    File.open(file) do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end
  end

  def save_html(file : String, html : String)
    File.open(file, "w") do |io|
      if file.ends_with?(".gz")
        Compress::Gzip::Writer.open(io, &.print(html))
      else
        io.print(html)
      end
    end
  end

  def staled?(file : String, expiry : Time) : Bool
    return true unless stats = File.info?(file)
    stats.modification_time < expiry
  end

  def get_html(url : String, encoding : String = "UTF-8", label = "1/1") : String
    try = 0
    internal = use_crystal?(url)

    loop do
      puts "-- <#{label}> [GET: <#{url}> (try: #{try})]".colorize.magenta
      html = internal ? get_by_crystal(url, encoding) : get_by_curl(url, encoding)
      return fix_charset(html, encoding) if html[0]? == '<'
    rescue err
      puts "<http_utils> #{url} err: #{err}".colorize.red
    ensure
      try += 1
      sleep 200.milliseconds * try
      raise "[GET: #{url} failed after 3 attempts.]" if try > 2
    end
  end

  private def use_crystal?(url : String)
    case url
    when .includes?("biquge5200"), .includes?("paoshu8")
      true
    else
      false
    end
  end

  def get_by_crystal(url : String, encoding : String)
    HTTP::Client.get(url) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.gets_to_end.lstrip
    end
  end

  def get_by_curl(url : String, encoding : String) : String
    cmd = "curl -L -k -s -m 30 '#{url}'"
    cmd += " | iconv -c -f #{encoding} -t UTF-8" if encoding != "UTF-8"

    `#{cmd}`.lstrip
  end

  private def fix_charset(html : String, encoding : String)
    return html if encoding == "UTF-8"
    html.sub(/charset=#{encoding}/i, "charset=utf-8")
  end

  def encoding_for(sname : String) : String
    case sname
    when "jx_la", "hetushu", "paoshu8", "zhwenpg", "zxcs_me", "bxwxorg"
      "UTF-8"
    else
      "GBK"
    end
  end

  def fetch_file(url : String, out_file : String) : Nil
    cmd = "curl -L -k -s -m 100 '#{url}' -o '#{out_file}'"
    try = 0

    loop do
      puts "[FETCH_FILE: <#{url}> (try: #{try})]".colorize.magenta
      puts `#{cmd}`

      return if File.exists?(out_file)

      try += 1
      sleep 250.milliseconds * try
      raise "500 Server Error!" if try > 3
    end
  end
end
