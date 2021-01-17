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

    if uname = env.session.string?("dname").try(&.downcase)
      nvmark = Marked.user_books(uname).fval(bhash) || ""
    else
      nvmark = ""
    end

    RouteUtils.json_res(env, cached: nvinfo.update_tz) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "nvinfo" { nvinfo.to_json(json, true) }
          json.field "nvmark", nvmark
        end
      end
    end
  end
end
