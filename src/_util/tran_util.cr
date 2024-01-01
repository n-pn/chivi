require "log"
require "json"
require "http/client"
require "../cv_env"

module TranUtil
  extend self

  CVMTL_URL = "#{CV_ENV.m1_host}/_m1/qtran"

  BTRAN_URL = "#{CV_ENV.sp_host}/_sp/btran"
  DEEPL_URL = "#{CV_ENV.sp_host}/_sp/deepl"

  BTRAN_NO_CAP = "#{CV_ENV.sp_host}/_sp/qtran?no_cap=true"
  DEEPL_NO_CAP = "#{CV_ENV.sp_host}/_sp/deepl?no_cap=true"

  JSON_HEADER = HTTP::Headers{"Content-Type" => "application/json"}
  TEXT_HEADER = HTTP::Headers{"Content-Type" => "text/plain"}

  def qtran(input : String, wn_id : Int32 = 0, format = "mtl") : String?
    url = "#{CVMTL_URL}?wn_id=#{wn_id}&format=#{format}"
    call_api(url, TEXT_HEADER, input)
  end

  def btran(input : String, no_cap : Bool = false) : String?
    call_api(no_cap ? BTRAN_NO_CAP : BTRAN_URL, TEXT_HEADER, input)
  end

  def deepl(input : String, no_cap : Bool = false) : String?
    call_api(no_cap ? DEEPL_NO_CAP : DEEPL_URL, TEXT_HEADER, input)
  end

  private def call_api(url : String, headers : HTTP::Headers, body : String) : String?
    HTTP::Client.post(url, headers: headers, body: body) do |res|
      text = res.body_io.gets_to_end
      return text if res.status.success?
      Log.error { "<#{url}> <#{body}>: #{text}".colorize.red }
    end
  end

  record Wndata, btitle : String, author : String, bintro : String do
    include JSON::Serializable
  end

  def tl_wndata(btitle : String, author : String, bintro : String, wn_id = 0)
    url = "#{CVMTL_URL}/wnovel?wn_id=#{wn_id}"
    body = {btitle: btitle, author: author, bintro: bintro}

    HTTP::Client.post(url, headers: JSON_HEADER, body: body.to_json) do |res|
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
      input.split('\n').join(io, '\n') { |x| io << "<p>" << x << "</p>" }
    end
  end
end
