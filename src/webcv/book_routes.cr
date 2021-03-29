require "./_route_utils"
require "../appcv/marked"

module CV::Server
  get "/api/nvinfos" do |env|
    matched = NvInfo.filter(env.params.query)
    RouteUtils.books_res(env, matched)
  end

  get "/api/nvinfos/:bslug" do |env|
    unless bhash = NvInfo.find_by_slug(env.params.url["bslug"])
      halt env, status_code: 404, response: "Book not found!"
    end

    spawn NvOrders.set_access!(bhash, Time.utc.to_unix // 60)

    RouteUtils.json_res(env) do |res|
      nvinfo = NvInfo.load(bhash)
      JSON.build(res) { |json| nvinfo.to_json(json, true) }
    end
  end
end
