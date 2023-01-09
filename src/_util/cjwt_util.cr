require "jwt"
require "../config"

module CjwtUtil
  extend self

  ALGORITHM = JWT::Algorithm::HS256

  USER_EXP = 60 * 15
  AUTH_EXP = 60 * 60 * 24 * 365

  def encode_user_token(id : Int32, uname : String, privi : Int32) : String
    payload = {id: id, uname: uname, privi: privi, exp: Time.utc.to_unix + USER_EXP}
    JWT.encode(payload, CV::Config.jwt_user_key, ALGORITHM)
  end

  def encode_auth_token(uname : String) : String
    payload = {uname: uname, exp: Time.utc.to_unix + AUTH_EXP}
    JWT.encode(payload, CV::Config.jwt_auth_key, ALGORITHM)
  end

  def decode_user_token(token : String) : {Int32, String, Int32}
    payload = JWT.decode(token, CV::Config.jwt_user_skey, ALGORITHM).first.as_h
    {payload["id"].as_i, payload["uname"].as_s, payload["privi"].as_i}
  rescue
    {0, "Khách", -1}
  end

  def decode_auth_token(token : String) : String
    payload = JWT.decode(token, CV::Config.jwt_auth_skey, ALGORITHM).first.as_h
    payload["uname"].as_s
  rescue
    "Khách"
  end
end
