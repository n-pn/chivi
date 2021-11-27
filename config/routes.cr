Amber::Server.configure do
  pipeline :api do
    # plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::ClientIp.new(["X-Forwarded-For"])
    plug Amber::Pipe::Error.new
    # plug Amber::Pipe::Logger.new(filter: ["upass"])
    # plug Amber::Pipe::Session.new # do it manually
    # plug Amber::Pipe::CORS.new
  end

  # All static content will run these transformations
  pipeline :static do
    # plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Static.new("./priv/static")
  end

  routes :api, "/api" do
    get "/user/_self", CV::CvuserCtrl, :_self
    get "/user/logout", CV::CvuserCtrl, :logout
    post "/user/login", CV::CvuserCtrl, :login
    post "/user/signup", CV::CvuserCtrl, :signup
    put "/user/setting", CV::CvuserCtrl, :update
    put "/user/passwd", CV::CvuserCtrl, :passwd

    get "/authors/:author_id/books", CV::AuthorCtrl, :books

    get "/books", CV::NvinfoCtrl, :index
    get "/books/find/:bname", CV::NvinfoCtrl, :find
    get "/books/:bslug", CV::NvinfoCtrl, :show

    get "/chaps/:book/:sname", CV::NvchapCtrl, :index
    get "/chaps/:book/:sname/:chidx/:cpart", CV::NvchapCtrl, :show
    get "/chaps/:book/:sname/:chidx/:cpart/text", CV::NvchapCtrl, :text
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
    get "/dicts/:dname/search", CV::VpdictCtrl, :search
    put "/dicts/:dname/search", CV::VpdictCtrl, :search
    put "/dicts/:dname/upsert", CV::VpdictCtrl, :upsert

    get "/qtrans/crits/:name", CV::QtransCtrl, :show_crit
    get "/qtrans/notes/:name", CV::QtransCtrl, :show_note
    get "/qtrans/posts/:name", CV::QtransCtrl, :show_post
    post "/qtrans/posts", CV::QtransCtrl, :qtran

    get "/boards/", CV::DboardCtrl, :index
    get "/boards/:dboard", CV::DboardCtrl, :show

    get "/topics", CV::DtopicCtrl, :index
    get "/boards/:dboard/topics", CV::DtopicCtrl, :index

    get "/topics/:dtopic", CV::DtopicCtrl, :show

    post "/boards/:dboard/new", CV::DtopicCtrl, :create
    put "/boards/:dboard/:dtopic", CV::DtopicCtrl, :update

    get "/tlspecs/", CV::TlspecCtrl, :index
    get "/tlspecs/:ukey", CV::TlspecCtrl, :show
    post "/tlspecs", CV::TlspecCtrl, :create
    put "/tlspecs/:ukey", CV::TlspecCtrl, :update
    delete "/tlspecs/:ukey", CV::TlspecCtrl, :delete
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
