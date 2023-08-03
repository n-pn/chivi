require "http/client"

cookies = ""
headers = HTTP::Headers{
  "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/112.0",
  "Cookie"     => cookies,
}
