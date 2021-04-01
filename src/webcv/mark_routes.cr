require "./_route_utils"
require "../appcv/nv_info"
require "../appcv/ch_info"
require "../appcv/vi_mark"

module CV::Server
  get "/api/@:uname/books" do |env|
    uname = env.params.url["uname"].downcase
    bmark = env.params.query["bmark"]? || "reading"
    matched = ViMark.all_books(uname, bmark)
    RouteUtils.books_res(env, matched)
  end

  get "/api/mark-books/:bname" do |env|
    if uname = env.session.string?("u_dname").try(&.downcase)
      bname = env.params.url["bname"]
      bmark = ViMark.book_map(uname).fval(bname) || ""
    end

    RouteUtils.json_res(env, {bmark: bmark || ""})
  end

  put "/api/mark-books/:bname" do |env|
    unless uname = env.session.string?("u_dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in!"
    end

    bname = env.params.url["bname"]
    bmark = env.params.json["bmark"]?.as(String?) || ""
    ViMark.mark_book(uname, bname, bmark)

    RouteUtils.json_res(env, {bmark: bmark})
  end

  get "/api/mark-chaps" do |env|
    unless uname = env.session.string?("u_dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in!"
    end

    skip = env.params.query.fetch("skip", "0").to_i
    take = env.params.query.fetch("take", "10").to_i

    chap_mark = ViMark.chap_map(uname)
    iter = chap_mark._idx.reverse_each
    skip.times { break unless iter.next }

    env.response.headers.add("Cache-Control", "min-fresh=300")
    env.response.headers.add("ETag", iter.try(&.curr.val.to_s) || "0")

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.array do
          take.times do
            break unless node = iter.next

            nvinfo = NvInfo.load(node.key)
            next unless vals = chap_mark.get(nvinfo.bhash)
            atime, sname, chidx, title, uslug = vals

            json.object do
              json.field "bname", nvinfo.btitle[2]
              json.field "bslug", nvinfo.bslug
              json.field "atime", atime
              json.field "sname", sname
              json.field "chidx", chidx
              json.field "title", title
              json.field "uslug", uslug
            end
          end
        end
      end
    end
  end
end
