require "http/client"

def get_page(link : String, save_path : String) : Nil
  HTTP::Client.get(link) { |res| File.open(save_path, "wb") { |file| IO.copy(res.body_io, file) } }
end

get_page "https://m.xklxsw.com/book/250781/205813580.html", "tmp/xklxsw.html"
