require "./_route_utils"
require "../filedb/marked"

module CV::Server
  get "/api/nvinfos" do |env|
    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 24)

    matched = NvTokens.glob(env.params.query)
    RouteUtils.books_res(env, matched)
  end

  get "/api/nvinfos/:bslug" do |env|
    unless bhash = Nvinfo.find_by_slug(env.params.url["bslug"])
      halt env, status_code: 404, response: "Book not found!"
    end

    nvinfo = Nvinfo.load(bhash)
    nvinfo.bump_access!

    RouteUtils.json_res(env, cached: nvinfo._utime) do |res|
      JSON.build(res) do |json|
        nvinfo.to_json(json, true)
      end
    end
  end
end
