require "colorize"
require "http/client"
require "./gzip_file"

module CV::HttpUtil
  extend self

  TTL = Time.utc(2021, 1, 1, 7, 0, 0)

  def load_html(url : String, file : String, ttl = TTL, lbl = "1/1", encoding = "UTF-8")
    GzipFile.new(file).read(ttl) { get_html(url, encoding: encoding, lbl: lbl) }
  end

  def get_html(url : String, lbl = "1/1", encoding = "UTF-8") : String
    try = 0

    loop do
      puts "-- <#{lbl.colorize.magenta}> \
               [GET: #{url.colorize.magenta} \
               (try: #{try.colorize.magenta})]"

      html = get_by_curl(url, encoding)
      return replace_charset(html, encoding) unless html.empty?
    rescue err
      puts "<http_utils> #{url} err: #{err}".colorize.red
    ensure
      try += 1
      sleep 500.milliseconds * try
      raise "[GET: #{url} failed after 2 attempts.]" if try > 2
    end
  end

  def get_by_curl(url : String, encoding : String) : String
    cmd = "curl -L -k -s -f -m 30 '#{url}'"
    cmd += " | iconv -c -f #{encoding} -t UTF-8" if encoding != "UTF-8"
    `#{cmd}`.lstrip
  end

  def crystal_get(url : String, encoding : String)
    HTTP::Client.get(url) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.gets_to_end.lstrip
    end
  end

  private def replace_charset(html : String, encoding : String)
    encoding == "UTF-8" ? html : html.sub(/charset=#{encoding}/i, "charset=utf-8")
  end

  UTF_8 = {"jx_la", "hetushu", "paoshu8", "zhwenpg", "zxcs_me", "bxwxorg", "nofff"}

  def encoding_for(sname : String) : String
    UTF_8.includes?(sname) ? "UTF-8" : "GBK"
  end

  def fetch_file(url : String, file : String, lbl = "1/1") : Nil
    try = 0

    loop do
      puts "- <#{lbl.colorize.magenta}> \
              [GET: #{url.colorize.magenta}, \
              (try: #{try.colorize.magenta})]"

      `curl -L -k -s -f -m 100 '#{url}' -o '#{file}'`
      return if File.exists?(file)
    ensure
      try += 1
      sleep 500.milliseconds * try
      raise "[DL: #{url} failed after 3 attempts.]" if try > 2
    end
  end
end
