require "http/client"

module Rmutil
  extend self

  def still_fresh?(file_path : String, stale : Time) : Bool
    File.info?(file_path).try(&.modification_time.> stale) || false
  end

  ###

  def http_client(base_url : String)
    HTTP::Client.new(base_url)
  end

  USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0"

  def get_headers(referer = "", cookie = "")
    HTTP::Headers{
      "User-Agent" => USER_AGENT,
      "Referer"    => referer,
      "Cookie"     => cookie,
    }
  end

  def xhr_headers(referer = "", cookie = "")
    HTTP::Headers{
      "X-Requested-With" => "XMLHttpRequest",
      "Content-Type"     => "application/x-www-form-urlencoded",
      "User-Agent"       => USER_AGENT,
      "Referer"          => referer,
      "Cookie"           => cookie,
    }
  end

  TIMEZONE = Time::Location.fixed(3600 * 8) # chinese timezone

  def parse_time(date : String, fmt = "%F %T", full_datetime = fmt == "%F %T")
    time = Time.parse(date, fmt, TIMEZONE)
    return time if full_datetime

    time += 1.days
    time > Time.utc ? Time.utc : time
  end

  ###

  def clean_text(input : String)
    input.tr("\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000\t\n", " ").strip
  end

  def clean_para(input : String)
    input.split(/\R+|\s{2,}/, remove_empty: true).map! { |line| clean_text(line) }.join('\n')
  end
end
