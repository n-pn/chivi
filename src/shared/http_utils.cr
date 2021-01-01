require "colorize"
require "http/client"

# require "crest"

module CV::HttpUtils
  extend self

  def get_html(url : String, encoding : String) : String
    cmd = "curl #{url} -L -k -s -m 30"
    cmd += " | iconv -f #{encoding} -t UTF-8" if encoding != "UTF-8"

    try = 0

    loop do
      puts "[GET: <#{url}> (try: #{try})]".colorize.magenta

      html = `#{cmd}`
      return html unless html.empty?

      try += 1
      sleep 500.milliseconds * try
      raise "500 Server Error!" if try > 5
    end
  end

  def encoding_for(seed : String) : String
    case seed
    when "jx_la", "hetushu", "paoshu8", "zhwenpg", "zxcs_me"
      "UTF-8"
    else
      "GBK"
    end
  end
end
