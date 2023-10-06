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

  ###

  def clean_text(input : String)
    input.tr("\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000\t\n", " ").strip
  end

  def clean_para(input : String)
    input.split(/\R+|\s{2,}/, remove_empty: true).map! { |line| clean_text(line) }.join('\n')
  end

  extend self

  FINISH = {
    "已完结",
    "全本",
    "完结",
    "已完本",
    "暂停",
    "完结申请",
    "完本",
    "已完成",
    "新书上传",
    "已经完结",
    "完成",
    "已经完本",
    "finish",
  }

  HIATUS = {
    "暂停",
    "暂 停",
    "暂　停",
  }

  def parse_status(status_str : String)
    case status_str
    when .in?(HIATUS)   then 2_i16
    when .in?(FINISHED) then 1_i16
    else                     0_i16
    end
  end

  TIMEZONE = Time::Location.fixed(3600 * 8) # chinese timezone

  def parse_rmtime(update_str : String,
                   time_fmt = "%F %T",
                   precise = time_fmt == "%F %T")
    return 0_i64 if update_str.empty?
    time = Time.parse(update_str, time_fmt, TIMEZONE)
    time += 1.days unless precise
    time > Time.utc ? Time.utc : time
  rescue ex
    Log.error(exception: ex) { update_str }
    0_i64
  end
end
