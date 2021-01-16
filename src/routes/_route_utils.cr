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

  def books_res(env, matched : Set(String)? = nil)
    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 24)

    sorts = Nvinfo.get_order_map(env.params.query["order"]?)
    total = matched ? matched.size : sorts.size

    json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", total

          json.field "books" do
            json.array do
              Nvinfo.each(sorts, skip: skip, take: take, matched: matched) do |bhash|
                Nvinfo.new(bhash).to_json(json, false)
              end
            end
          end
        end
      end
    end
  end
end
