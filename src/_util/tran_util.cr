require "log"
require "http/client"

module TranUtil
  extend self

  CVMTL_URL = "http://localhost:5010/api/qtran"
  BTRAN_URL = "http://localhost:5401/_mh/btran"
  DEEPL_URL = "http://localhost:5401/_mh/deepl"

  BTRAN_NO_CAP = "http://localhost:5010/api/qtran?no_cap=true"
  DEEPL_NO_CAP = "http://localhost:5010/api/deepl?no_cap=true"

  JSON_HEADER = HTTP::Headers{"content-type" => "application/json"}
  TEXT_HEADER = HTTP::Headers{"content-type" => "text/plain"}

  def qtran(input : String, dname : String) : String?
    body = {input: input, dname: dname, mode: "plain"}.to_json
    call_api(CVMTL_URL, JSON_HEADER, body)
  end

  def btran(input : String, no_cap : Bool = false) : String?
    call_api(no_cap ? BTRAN_NO_CAP : BTRAN_URL, TEXT_HEADER, input)
  end

  def deepl(input : String, no_cap : Bool = false) : String?
    call_api(no_cap ? DEEPL_NO_CAP : DEEPL_URL, TEXT_HEADER, input)
  end

  private def call_api(url : String, headers : HTTP::Headers, body : String) : String?
    HTTP::Client.put(url, headers: headers, body: body) do |res|
      return res.body_io.gets_to_end if res.status.success?
      Log.error { "error: #{res.body}" }
    end
  rescue err
    Log.error(exception: err) { err.message }
  end
end
