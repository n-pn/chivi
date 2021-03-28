require "./_route_utils"
require "../appcv/marked"

module CV::Server
  get "/api/nvinfos" do |env|
    matched = NvIndex.filter(env.params.query)
    RouteUtils.books_res(env, matched)
  end

  get "/api/nvinfos/:bslug" do |env|
    unless bhash = NvInfo.find_by_slug(env.params.url["bslug"])
      halt env, status_code: 404, response: "Book not found!"
    end

    nvinfo = NvInfo.load(bhash)
    NvInfo.load(bhash).bump_access!

    RouteUtils.json_res(env, cached: nvinfo.mftime) do |res|
      JSON.build(res) { |json| nvinfo.to_json(json, true) }
    end
  end
end
