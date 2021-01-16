require "./_route_utils"
require "../filedb/nvmark"

module CV::Server
  get "/api/nvinfos" do |env|
    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 24)

    matched = Nvinfo::Tokens.glob(env.params.query)
    ordered = Nvinfo.get_order_map(env.params.query["order"]?)

    total = matched ? matched.size : ordered.size

    books = [] of Nvinfo::BasicInfo
    Nvinfo.each(ordered, skip: skip, take: take, matched: matched) do |bhash|
      books << Nvinfo.get_cached_basic_info(bhash)
    end

    RouteUtils.json_res(env, {books: books, total: total})
  end

  get "/api/nvinfos/:bslug" do |env|
    unless bhash = Nvinfo.find_by_slug(env.params.url["bslug"])
      halt env, status_code: 404, response: "Book not found!"
    end

    Nvinfo.bump_access!(bhash)

    if uname = env.session.string?("dname").try(&.downcase)
      bmark = Nvmark.user_books(uname).fval(bhash) || ""
    else
      bmark = ""
    end

    basic_info = Nvinfo.get_cached_basic_info(bhash)
    extra_info = Nvinfo.get_extra_info(bhash)

    RouteUtils.json_res(env, {basic: basic_info, extra: extra_info, bmark: bmark}, cached: extra_info.update_tz)
  end
end
