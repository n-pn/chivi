require "colorize"
require "http/client"

# require "crest"

module CV::HttpUtils
  extend self

  def get_html(url : String) : String
    puts "-- GET: [#{url}]".colorize.magenta

    cmd = "curl #{url} -L -k -s -m 30"
    cmd += " | iconv -f GBK -t UTF-8" if is_gbk?(url)

    try = 0

    loop do
      html = `#{cmd}`
      return html unless html.empty?

      try += 1
      sleep 500.milliseconds * try
      raise "500 Server Error!" if try > 5
    end
  end

  def is_gbk?(url : String) : Bool
    case URI.parse(url).host
    when "www.jx.la",
         "www.hetushu.com",
         "www.paoshu8.com",
         "novel.zhwenpg.com",
         "www.zxcs.me"
      false
    else
      true
    end
  end
end
