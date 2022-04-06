Amber::Server.configure do
  pipeline :api do
    plug Amber::Pipe::PoweredByAmber.new
    plug CV::Pipe::ClientIp.new("X-Forwarded-For")
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new(filter: ["upass"])
    # plug Amber::Pipe::Session.new # do it manually
    plug Amber::Pipe::CORS.new
  end

  # All static content will run these transformations
  pipeline :static do
    plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Static.new("./priv/static")
  end

  routes :api, "/api" do
    get "/user/logout", CV::CvuserCtrl, :logout
    post "/user/login", CV::CvuserCtrl, :login
    post "/user/signup", CV::CvuserCtrl, :signup
    put "/user/setting", CV::CvuserCtrl, :update
    post "/user/pwtemp", CV::CvuserCtrl, :pwtemp
    put "/user/passwd", CV::CvuserCtrl, :passwd

    get "/_self", CV::UsercpCtrl, :cv_user
    get "/_self/replied", CV::UsercpCtrl, :replied
    put "/_self/upgrade", CV::UsercpCtrl, :upgrade

    # get "/authors/:author_id/books", CV::AuthorCtrl, :books

    get "/books", CV::NvinfoCtrl, :index
    put "/books", CV::NvinfoCtrl, :upsert
    post "/books", CV::NvinfoCtrl, :upsert
    get "/books/:bslug", CV::NvinfoCtrl, :show
    get "/books/:bhash/front", CV::NvinfoCtrl, :front

    get "/chaps/:book", CV::NvchapCtrl, :ch_seed
    get "/chaps/:book/:sname", CV::NvchapCtrl, :ch_list

    get "/chaps/:book/:sname/:chidx/_raw", CV::NvchapCtrl, :zh_text
    get "/chaps/:book/:sname/:chidx/:cpart", CV::NvchapCtrl, :ch_info

    get "/chaps/:book/:sname/:chidx/:cpart/text", CV::NvchapCtrl, :cv_text
    post "/chaps/:book/:sname", CV::NvchapCtrl, :upsert

    get "/crits", CV::YscritCtrl, :index
    get "/crits/:crit", CV::YscritCtrl, :show
    get "/crits/:crit/replies", CV::YscritCtrl, :replies

    get "/_self/books", CV::UbmemoCtrl, :cvbook
    get "/_self/books/access", CV::UbmemoCtrl, :access

    get "/_self/books/:book_id", CV::UbmemoCtrl, :show
    put "/_self/books/:book_id/status", CV::UbmemoCtrl, :update_status
    put "/_self/books/:book_id/access", CV::UbmemoCtrl, :update_access

    get "/dicts", CV::VpdictCtrl, :index
    get "/dicts/:dname", CV::VpdictCtrl, :show
    get "/dicts/:dname/lookup", CV::VpdictCtrl, :lookup
    put "/dicts/:dname/lookup", CV::VpdictCtrl, :lookup

    post "/terms/query", CV::VptermCtrl, :lookup
    put "/terms/entry", CV::VptermCtrl, :upsert_entry
    post "/terms/batch", CV::VptermCtrl, :upsert_batch

    get "/qtran/:type/:name", CV::QtransCtrl, :show
    post "/qtran", CV::QtransCtrl, :qtran
    post "/qtran/posts", CV::QtransCtrl, :create_post

    get "/boards/", CV::DboardCtrl, :index
    get "/boards/:dboard", CV::DboardCtrl, :show

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

    get "/tlspecs/", CV::TlspecCtrl, :index
    get "/tlspecs/:ukey", CV::TlspecCtrl, :show
    post "/tlspecs", CV::TlspecCtrl, :create
    post "/tlspecs/:ukey", CV::TlspecCtrl, :update
    delete "/tlspecs/:ukey", CV::TlspecCtrl, :delete
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
