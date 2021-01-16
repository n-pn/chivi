require "kemal"
require "kemal-session"

require "../_oldcv/engine"
require "../kernel"

module CV::Server::RouteUtils
  extend self

  def parse_page(page : String, limit = 24)
    page = page.to_i? || 1

    offset = (page - 1) * limit
    offset = 0 if offset < 0

    {limit, offset}
  end

  def search_page(page : String?)
    return 1 unless page = page.try(&.to_i?)
    page = 1 if page < 1
    page
  end

  def search_limit(limit : String?, upper = 24)
    return upper unless limit = limit.try(&.to_i?)
    limit < 1 || limit > upper ? upper : limit
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
