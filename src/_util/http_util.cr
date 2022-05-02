require "log"
require "colorize"
require "compress/gzip"

module CV::HttpUtil
  extend self

  UTF8 = {
    "jx_la", "zxcs_me", "xswang",
    "hetushu", "paoshu8", "zhwenpg",
    "bxwxorg", "sdyfcm",
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
      cmd += %q{ | sed -r 's/charset=\"?GBK\"?/charset=utf-8/i'}
    end

    loop do
      Log.info { "<#{lbl}> [GET: #{url.colorize.magenta} (try: #{try})]" }
      html = `#{cmd}`
      return html unless html.empty?
    rescue err
      Log.error { err.inspect_with_backtrace }
    ensure
      raise "[GET: #{url} failed after 3 attempts.]" if try > 2
      try += 1
      sleep 250.milliseconds * try
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

  def save_image(link : String, file : String, webp_file : String)
    return if File.exists?(webp_file) || link.blank?
    return unless img_file = fetch_image(link, file)

    if img_file.ends_with?(".gif")
      gif_to_webp(img_file, webp_file)
    elsif img_width = image_width(img_file)
      img_to_webp(img_file, webp_file, img_width)
    end
  end

  def fetch_image(link : String, img_file : String) : String?
    return img_file if File.exists?(img_file)
    Log.info { "Fetch image: #{link}" }

    HTTP::Client.get(link) do |res|
      ext = map_extension(res.content_type)
      img_file = img_file.sub(".jpg", ext)

      Dir.mkdir_p(File.dirname(img_file))
      File.write(img_file, res.body_io)
    end

    Log.info { "[#{link}] saved to [#{img_file}]".colorize.yellow }
    img_file
  rescue err
    Log.error { err.colorize.red }
  end

  def map_extension(mime : String?) : String
    case mime
    when .nil?        then ".raw"
    when "image/jpeg" then ".jpg"
    when "image/png"  then ".png"
    when "image/gif"  then ".gif"
    when "image/webp" then ".webp"
    when "text/html"  then ".html"
    else
      exts = MIME.extensions(mime)
      exts.empty? ? ".jpg" : exts.first
    end
  end

  def image_width(file : String, delete = false) : Int32?
    return unless File.exists?(file)
    `identify -format '%w %h' "#{file}"`.split(" ").first.to_i?
  rescue err
    Log.error { [file, err].colorize.red }
    File.delete(file) if delete
  end

  def gif_to_webp(inp_file : String, out_file : String)
    `gif2webp -quiet "#{inp_file}" -o "#{out_file}"`
    # return unless width = image_width(out_file)
    # img_to_webp(out_file, out_file, width)
  end

  def img_to_webp(inp_file : String, out_file : String, width = 300)
    webp_cmd = "cwebp -quiet -q 100 -mt"
    webp_cmd += " -resize 300 0" if width > 300
    webp_cmd += %{ "#{inp_file}" -o "#{out_file}"}
    `#{webp_cmd}`
  end
end
