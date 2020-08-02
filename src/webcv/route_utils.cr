require "kemal"
require "kemal-session"

require "../libcv"
require "../appcv"

module Server::Utils
  extend self

  def parse_page(input, limit = 20)
    page = input.to_i? || 0

    offset = (page - 1) * limit
    offset = 0 if offset < 0

    {limit, offset}
  end

  def json_error(msg : String)
    {msg: msg}.to_json
  end

  def return_user(env, user : UserInfo)
    env.session.string("uslug", user.uslug)
    {status: "ok", uname: user.uname, power: user.power}.to_json(env.response)
  end
end
