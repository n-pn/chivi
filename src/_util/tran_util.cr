require "log"
require "json"
require "http/client"

require "../cv_env"

module TranUtil
  extend self

  JSON_HEADERS = HTTP::Headers{"Content-Type" => "application/json"}
  TEXT_HEADERS = HTTP::Headers{"Content-Type" => "text/plain"}

  QTRAN_URL = "#{CV_ENV.sp_host}/_sp/qtran"

  def call_api(body : String, type : String = "qt_v1", opts : String = "")
    url = "#{QTRAN_URL}/#{type}"
    url += "?opts=#{opts}" unless opts.empty?

    HTTP::Client.post(url, headers: TEXT_HEADERS, body: body) do |res|
      text = res.body_io.gets_to_end
      return text if res.status.success?
      Log.error { "<#{url}> <#{body}>: #{text}".colorize.red }
    end
  end

  CVMTL_URL = "#{CV_ENV.m1_host}/_m1/qtran"

  record Wndata, btitle : String, author : String, bintro : String do
    include JSON::Serializable
  end

  def tl_wndata(btitle : String, author : String, bintro : String, wn_id = 0)
    url = "#{CVMTL_URL}/wnovel?wn_id=#{wn_id}"
    body = {btitle: btitle, author: author, bintro: bintro}

    HTTP::Client.post(url, headers: JSON_HEADERS, body: body.to_json) do |res|
      return unless res.success?
      Wndata.from_json(res.body_io)
    end
  end

  def opencc(input : String, config = "hk2s") : String
    Process.run("/usr/bin/opencc", {"-c", config}) do |proc|
      output = String::Builder.new

      input.each_line do |line|
        if line.blank?
          output << line << '\n'
        else
          proc.input.puts(line)
          output << proc.output.gets << '\n'
        end
      end

      proc.input.close
      output.to_s
    rescue ex
      Log.error(exception: ex) { input }
      input
    end
  end

  def txt_to_htm(input : String)
    String.build do |io|
      input.each_line do |line|
        io << "<p>" << line.gsub('<', "&gt;") << "</p>" << '\n'
      end
    end
  end
end
