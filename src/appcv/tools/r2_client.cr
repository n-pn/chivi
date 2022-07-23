module CV::R2Client
  extend self

  R2_ROOT = ENV["R2_ROOT"]? || "https://r2.chivi.app/"
  HEADERS = HTTP::Headers{"X-Custom-Auth-Key" => ENV["R2_AUTH"]}

  def upload(path : String, file : String) : Bool
    res = HTTP::Client.put("#{R2_ROOT}#{path}", HEADERS, body: File.read(file))
    res.status_code < 400
  end

  def download(path : String, file : String) : Bool
    # TODO: replace with internal http/client?
    `curl "#{R2_ROOT}#{path}" -o "#{file}"`
    $?.success?
  end
end
