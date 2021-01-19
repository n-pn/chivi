require "./_route_utils"
require "../filedb/marked"

module CV::Server
  get "/api/nvinfos" do |env|
    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 24)

    matched = NvTokens.glob(env.params.query)
    RouteUtils.books_res(env, matched)
  end

  get "/api/nvinfos/:b_slug" do |env|
    unless b_hash = Nvinfo.find_by_slug(env.params.url["b_slug"])
      halt env, status_code: 404, response: "Book not found!"
    end

    nvinfo = Nvinfo.load(b_hash)
    nvinfo.bump_access!

    if u_uname = env.session.string?("u_dname").try(&.downcase)
      nvmark = Marked.user_books(u_uname).fval(b_hash) || ""
    else
      nvmark = ""
    end

    RouteUtils.json_res(env, cached: nvinfo._utime) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "nvinfo" { nvinfo.to_json(json, true) }
          json.field "nvmark", nvmark
        end
      end
    end
  end
end
