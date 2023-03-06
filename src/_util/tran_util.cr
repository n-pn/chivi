require "log"
require "http/client"

module TranUtil
  extend self

  CVMTL_URL = "http://localhost:5110/_m1/qtran"
  BTRAN_URL = "http://localhost:5501/_sp/btran"
  DEEPL_URL = "http://localhost:5501/_sp/deepl"

  BTRAN_NO_CAP = "http://localhost:5501/_sp/qtran?no_cap=true"
  DEEPL_NO_CAP = "http://localhost:5501/_sp/deepl?no_cap=true"

  JSON_HEADER = HTTP::Headers{"content-type" => "application/json"}
  TEXT_HEADER = HTTP::Headers{"content-type" => "text/plain"}

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

  alias BookTran = NamedTuple(btitle: String, author: String, bintro: String)

  def tl_book(btitle : String, author : String, bintro : String, wn_id = 0)
    url = "#{CVMTL_URL}/tl_wnovel?wn_id=#{wn_id}"
    body = {btitle: btitle, author: author, bintro: bintro}

    HTTP::Client.post(url, headers: JSON_HEADER, body: body.to_json) do |res|
      return unless res.success?
      data = BookTran.from_json(res.body_io)
      {data[:btitle], data[:author], data[:bintro]}
    end
  end

  private def call_api(url : String, headers : HTTP::Headers, body : String) : String?
    Log.debug { "CALL:#{url}" }

    HTTP::Client.put(url, headers: headers, body: body) do |res|
      body = res.body_io.gets_to_end
      return body if res.status.success?
      Log.error { "error call #{url}: #{body}" }
    end
  end

  def opencc(input : String, config = "hk2s")
    Process.run("/usr/bin/opencc", {"-c", config}) do |proc|
      proc.input.print(input)
      proc.input.close
      proc.output.gets_to_end
    rescue err
      Log.error(exception: err) { err.message }
      input
    end
  end
end
