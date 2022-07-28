require "log"
require "colorize"
require "compress/gzip"

module CV::HttpUtil
  extend self

  UTF8 = {
    "jx_la", "zxcs_me", "xswang",
    "hetushu", "paoshu8", "zhwenpg",
    "bxwxorg", "sdyfcm", "133txt",
    "biqugse", "bqxs520", "uuks",
    "yannuozw", "kanshu8",
  }

  def encoding_for(sname : String) : String
    UTF8.includes?(sname) ? "UTF-8" : "GBK"
  end

  def cache(file : String, url : String, ttl = 10.years, lbl = "-/-", encoding = "UTF-8")
    return read_gzip(file) if File.info?(file).try(&.modification_time.> Time.utc - ttl)
    fetch(url, lbl, encoding).tap { |data| save_gzip(file, data) }
  rescue
    read_gzip(file)
  end

  def read_gzip(file : String)
    File.open(file) { |io| Compress::Gzip::Reader.open(io, &.gets_to_end) }
  end

  def save_gzip(file : String, data : String)
    File.open(file, "w") { |io| Compress::Gzip::Writer.open(io, &.print(data)) }
  end

  def fetch(url : String, lbl = "-/-", encoding = "UTF-8") : String
    try = 1
    cmd = "curl -L -k -s -m 30 '#{url}'"

    if encoding != "UTF-8"
      cmd += " | iconv -c -f #{encoding} -t UTF-8"
      cmd += %q{ | sed -r 's/charset=\"?(gbk|gb2312)\"?/charset=utf-8/i'}
    end

    loop do
      # Log.info { "<#{lbl}> [GET: #{url.colorize.magenta} (try: #{try})]" }
      puts "<#{lbl}> [GET: #{url.colorize.magenta} (try: #{try})]"
      html = `#{cmd}`
      return html if $?.success?
    ensure
      raise "[GET: #{url} failed after #{try} attempts.]" if try > 3
      try += 1
      sleep 1.second * try
    end
  end

  # def get_by_curl(url : String, encoding : String) : String
  #   cmd = "curl -L -k -s -f -m 30 '#{url}'"
  #   cmd += " | iconv -c -f #{encoding} -t UTF-8" if encoding != "UTF-8"
  #   `#{cmd}`
  # end

  # def crystal_get(url : String, encoding : String)
  #   HTTP::Client.get(url) do |res|
  #     res.body_io.set_encoding(encoding, invalid: :skip)
  #     res.body_io.gets_to_end.lstrip
  #   end
  # end

  def fetch_file(url : String, file : String, lbl = "1/1") : Nil
    try = 0

    loop do
      puts "- <#{lbl.colorize.magenta}> [GET: #{url.colorize.magenta}, (try: #{try})]"

      `curl -L -k -s -f -m 200 '#{url}' -o '#{file}'`
      return if File.exists?(file)
    ensure
      try += 1
      sleep 500.milliseconds * try
      raise "[DL: #{url} failed after 3 attempts.]" if try > 2
    end
  end
end
