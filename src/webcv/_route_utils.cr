require "kemal"
require "kemal-session"

require "../appcv/*"

module CV::Server::RouteUtils
  extend self

  def parse_int(str : String?, min = 1, max = 9999999)
    return min unless str && (int = str.to_i?)
    int > max ? max : int > min ? int : min
  end

  def get_uname(env)
    env.session.string?("uname")
  end

  def get_power(env)
    get_uname(env).try { |uname| ViUser.get_power(uname) } || 0
  end

  def get_privi(env)
    mode = env.params.query.fetch("mode", "0").to_i? || 0

    power = get_power(env)
    mode = power if mode > power

    {power, mode}
  end

  def json_res(env, data, ttl = 0, etag = "")
    json_res(env, ttl: ttl, etag: etag) { |res| data.to_json(res) }
  end

  def json_res(env, ttl = 0, etag = "")
    env.response.headers.add("Cache-Control", "min-fresh=#{ttl * 60}") if ttl > 0
    env.response.headers.add("ETag", etag) unless etag.empty?
    env.response.content_type = "application/json"
    yield env.response
  end

  def books_res(env, matched : Set(String)? = nil)
    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 24)

    order = env.params.query["order"]? || "weight"
    total = matched ? matched.size : NvOrders.get(order).size

    json_res(env, ttl: 3) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", total

          json.field "books" do
            json.array do
              NvInfo.each(order, skip: skip, take: take + 1, matched: matched) do |bhash|
                NvInfo.load(bhash).to_json(json, false)
              end
            end
          end
        end
      end
    end
  end
end
