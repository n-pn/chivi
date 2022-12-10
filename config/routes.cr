Amber::Server.configure do
  pipeline :api do
    # plug Amber::Pipe::PoweredByAmber.new
    # plug CV::Pipe::ClientIp.new("X-Forwarded-For")
    plug CV::Pipe::Error.new
    plug Amber::Pipe::Logger.new(filter: ["upass"])
    # plug Amber::Pipe::Session.new # do it manually
    # plug Amber::Pipe::CORS.new
  end

  routes :api, "/api" do
    post "/_user/signup", CV::SigninCtrl, :signup
    post "/_user/log-in", CV::SigninCtrl, :log_in
    post "/_user/pwtemp", CV::SigninCtrl, :pwtemp
    delete "/_user/logout", CV::SigninCtrl, :logout

    get "/_self", CV::UsercpCtrl, :profile
    put "/_self/config", CV::UsercpCtrl, :update_config
    put "/_self/passwd", CV::UsercpCtrl, :update_passwd

    put "/_self/ugprivi", CV::UsercpCtrl, :upgrade_privi
    put "/_self/send-vcoin", CV::UsercpCtrl, :send_vcoin

    get "/_self/replied", CV::UsercpCtrl, :replied

    # get "/authors/:author_id/books", CV::AuthorCtrl, :books

    get "/ranks/brief", CV::NvrankCtrl, :brief

    get "/books", CV::NvinfoCtrl, :index
    post "/books", CV::NvinfoCtrl, :upsert
    get "/books/:bslug/+edit", CV::NvinfoCtrl, :edit

    get "/books/:bslug", CV::NvinfoCtrl, :show
    get "/books/:bslug/front", CV::NvinfoCtrl, :front
    delete "/books/:bslug", CV::NvinfoCtrl, :delete

    # nvseed actions

    get "/seeds/:nv_id", CV::ChrootCtrl, :index
    put "/seeds/:nv_id/", CV::ChrootCtrl, :create
    get "/seeds/:nv_id/:sname", CV::ChrootCtrl, :show
    get "/seeds/:nv_id/:sname/:page", CV::ChrootCtrl, :chaps
    put "/seeds/:nv_id/:sname/patch", CV::ChrootCtrl, :patch
    put "/seeds/:nv_id/:sname/trunc", CV::ChrootCtrl, :trunc
    delete "/seeds/:nv_id/:sname", CV::ChrootCtrl, :prune

    # nvchap actions

    get "/chaps/:nv_id/:sname/:chidx/:cpart", CV::ChinfoCtrl, :ch_info

    put "/texts/:nv_id/:sname", CV::ChtextCtrl, :upsert
    get "/texts/:nv_id/:sname/:chidx", CV::ChtextCtrl, :rawtxt
    # put "/texts/:nv_id/:sname/:chidx", CV::ChtextCtrl, :update
    patch "/texts/:nv_id/:sname/:chidx", CV::ChtextCtrl, :change

    get "/trans/:nv_id/:sname/:chidx/:part_no/:line_no", CV::ChtranCtrl, :list
    post "/trans/:nv_id/:sname/:chidx", CV::ChtranCtrl, :create

    # # member

    get "/_self/books", CV::UbmemoCtrl, :cvbook
    get "/_self/books/access", CV::UbmemoCtrl, :access

    get "/_self/books/:book_id", CV::UbmemoCtrl, :show
    put "/_self/books/:book_id/status", CV::UbmemoCtrl, :update_status
    put "/_self/books/:book_id/access", CV::UbmemoCtrl, :update_access

    # # dicts

    get "/dicts", CV::VpdictCtrl, :index
    get "/dicts/:dname", CV::VpdictCtrl, :show

    post "/terms/query", CV::VptermCtrl, :lookup
    put "/terms/entry", CV::VptermCtrl, :upsert_entry
    post "/terms/batch", CV::VptermCtrl, :upsert_batch

    # # quick trans

    # put "/qtran/hanviet", CV::QtransCtrl, :hanviet
    put "/qtran/mterror", CV::QtransCtrl, :mterror
    post "/qtran", CV::QtransCtrl, :webpage # to make the extension works
    put "/qtran", CV::QtransCtrl, :webpage  # to make the extension works
    get "/qtran/:type/:name", CV::QtransCtrl, :convert
    post "/qtran/posts", CV::QtransCtrl, :posts_upsert

    # # board

    get "/boards/", CV::DboardCtrl, :index
    get "/boards/:bslug", CV::DboardCtrl, :show

    get "/topics", CV::CvpostCtrl, :index
    post "/topics", CV::CvpostCtrl, :create

    get "/topics/:cvpost", CV::CvpostCtrl, :show
    get "/topics/:cvpost/detail", CV::CvpostCtrl, :detail

    post "/topics/:cvpost", CV::CvpostCtrl, :update
    delete "/topics/:cvpost", CV::CvpostCtrl, :delete

    get "/tposts", CV::CvreplCtrl, :index
    post "/tposts", CV::CvreplCtrl, :create
    get "/tposts/:cvrepl/detail", CV::CvreplCtrl, :detail
    post "/tposts/:cvrepl", CV::CvreplCtrl, :update
    delete "/tposts/:cvrepl", CV::CvreplCtrl, :delete

    # # report

    get "/tlspecs/", CV::TlspecCtrl, :index
    get "/tlspecs/:ukey", CV::TlspecCtrl, :show
    post "/tlspecs", CV::TlspecCtrl, :create
    post "/tlspecs/:ukey", CV::TlspecCtrl, :update
    delete "/tlspecs/:ukey", CV::TlspecCtrl, :delete

    put "/!posts/:post_ii/:action", CV::UsercpCtrl, :mark_post
    put "/!repls/:repl_id/:action", CV::UsercpCtrl, :mark_repl

    # get "/vpinits/fixtag/:source/:target", CV::VpinitCtrl, :fixtag
    # put "/vpinits/upsert/:target", CV::VpinitCtrl, :upsert

    # # review

    get "/crits/", CV::VicritCtrl, :index
    get "/crits/:crit", CV::VicritCtrl, :show
    post "/crits", CV::VicritCtrl, :create
    get "/crits/:crit/edit", CV::VicritCtrl, :edit
    patch "/crits/:crit", CV::VicritCtrl, :update
    delete "/crits", CV::VicritCtrl, :delete
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
