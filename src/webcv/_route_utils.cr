require "kemal"
require "kemal-session"

require "../appcv/*"

module CV::Server::RouteUtils
  extend self

  def parse_int(str : String?, min = 1, max = 9999999)
    return min unless str && (int = str.to_i?)
    int > max ? max : int > min ? int : min
  end

  def get_privi(env)
    u_power = env.session.int?("u_power") || 0
    mode = env.params.query["mode"]?.try(&.to_i?) || 0
    mode = u_power if mode > u_power
    {u_power, mode}
  end

  def json_res(env, data, cached = 0)
    json_res(env, cached: cached) { |res| data.to_json(res) }
  end

  def json_res(env, cached = 0)
    env.response.headers.add("ETag", cached.to_s) if cached > 0
    env.response.content_type = "application/json"
    yield env.response
  end

  def books_res(env, matched : Set(String)? = nil)
    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 24)

    sorts = NvIndex.order_map(env.params.query["order"]?)
    total = matched ? matched.size : sorts.size

    json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", total

          json.field "books" do
            json.array do
              NvInfo.each(sorts, skip: skip, take: take + 1, matched: matched) do |bhash|
                NvInfo.load(bhash).to_json(json, false)
              end
            end
          end
        end
      end
    end
  end
end
