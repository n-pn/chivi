require "kemal"
require "kemal-session"

require "../_oldcv/engine"
require "../kernel"

module CV::Server::RouteUtils
  extend self

  def parse_int(str : String?, min = 1, max = 24)
    return max unless str && (int = str.to_i?)
    int > max ? max : int > min ? int : min
  end

  def json_res(env, data, cached = 0)
    json_res(env, cached: cached) { |res| data.to_json(res) }
  end

  def json_res(env, cached = 0)
    if cached > 0
      env.response.headers.add("ETag", cached.to_s)
      env.response.headers.add("Cache-Control", "max-age=300")
    end

    env.response.content_type = "application/json"
    yield env.response
  end
end
