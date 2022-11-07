require "jwt"

ACCESS_TOKEN_SECRET  = {{ env("CV_ATSK") }}.not_nil!
REFRESH_TOKEN_SECRET = {{ env("CV_RTSK") }}.not_nil!

ALGORITHM = JWT::Algorithm::HS256

ACCESS_EXP  = 60 * 15
REFRESH_EXP = 60 * 60 * 24 * 365

def encode_access_token(uname : String, privi : Int32) : String
  payload = {
    "uname" => uname,
    "privi" => privi,
    "exp"   => Time.utc.to_unix + ACCESS_EXP,
  }

  JWT.encode(payload, ACCESS_TOKEN_SECRET, ALGORITHM)
end

def encode_refresh_token(uname : String) : String
  payload = {
    "uname" => uname,
    "exp"   => Time.utc.to_unix + REFRESH_EXP,
  }

  JWT.encode(payload, ACCESS_TOKEN_SECRET, ALGORITHM)
end

def decode_access_token(token : String) : {String, Int32}
  payload, _ = JWT.decode(token, ACCESS_TOKEN_SECRET, ALGORITHM)
  payload = payload.as_h

  {payload["uname"].as_s, payload["privi"].as_i}
rescue
  {"Khách", -1}
end

def decode_refresh_token(token : String) : String
  payload, _ = JWT.decode(token, ACCESS_TOKEN_SECRET, ALGORITHM)
  payload = payload.as_h

  payload["uname"].as_s
rescue
  "Khách"
end

case ARGV[0]?
when "e"
  uname = ARGV[1]? || "Khách"
  privi = ARGV[2]?.try(&.to_i) || -1
  puts encode_access_token(uname, privi)
  puts encode_refresh_token(uname)
when "da"
  puts decode_access_token(ARGV[1]).join("\n")
when "dr"
  puts decode_refresh_token(ARGV[1])
end
