require "./_route_utils"
require "../appcv/vi_mark"

module CV::Server
  get "/api/books" do |env|
    matched = NvInfo.filter(env.params.query)
    RouteUtils.books_res(env, matched)
  end

  get "/api/books/:bslug" do |env|
    bslug = env.params.url["bslug"]
    unless bhash = NvInfo.find_by_slug(bslug)
      halt env, status_code: 404, response: "Book not found!"
    end

    access = Time.utc.to_unix // 60
    NvOrders.set_access!(bhash, access, force: true)
    spawn { NvOrders.access.save!(clean: false) }

    RouteUtils.json_res(env) do |res|
      nvinfo = NvInfo.load(bhash)
      JSON.build(res) { |json| nvinfo.to_json(json, true) }
    end
  end
end
