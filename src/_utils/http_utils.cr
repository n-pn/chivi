require "colorize"
require "http/client"

# require "crest"

module CV::HttpUtils
  extend self

  def get_html(url : String, encoding : String) : String
    try = 0
    internal = url.includes?("biquge5200")

    loop do
      puts "[GET: <#{url}> (try: #{try})]".colorize.magenta
      html = internal ? get_by_crystal(url, encoding) : get_by_curl(url, encoding)
      return fix_charset(html, encoding) unless html.empty?
    rescue err
      puts err.colorize.red
    ensure
      try += 1
      sleep 500.milliseconds * try
      raise "500 Server Error!" if try > 3
    end
  end

  def get_by_crystal(url : String, encoding : String)
    tls = OpenSSL::SSL::Context::Client.insecure if url.starts_with?("https")

    HTTP::Client.get(url, tls: tls) do |res|
      res.body_io.set_encoding(encoding, invalid: :skip)
      res.body_io.gets_to_end
    end
  end

  def get_by_curl(url : String, encoding : String) : String
    cmd = "curl -L -k -s -m 30 '#{url}'"
    cmd += " | iconv -c -f #{encoding} -t UTF-8" if encoding != "UTF-8"
    `#{cmd}`.strip
  end

  private def fix_charset(html : String, encoding : String)
    return html if encoding == "UTF-8"
    html.sub(/charset=#{encoding}/i, "charset=utf-8")
  end

  private def fix_charset(html : String, encoding : String)
    return html if encoding == "UTF-8"
    html.sub(/charset=#{encoding}/i, "charset=utf-8")
  end

  def encoding_for(s_name : String) : String
    case s_name
    when "jx_la", "hetushu", "paoshu8", "zhwenpg", "zxcs_me"
      "UTF-8"
    else
      "GBK"
    end
  end

  def save_file(url : String, out_file : String) : Nil
    cmd = "curl -L -k -s -m 100 '#{url}' -o '#{out_file}'"
    try = 0

    loop do
      puts "[SAVE_FILE: <#{url}> (try: #{try})]".colorize.magenta
      `#{cmd}`
      return if File.exists?(out_file)

      try += 1
      sleep 500.milliseconds * try
      raise "500 Server Error!" if try > 3
    end
  end
end
