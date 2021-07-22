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
    get "/user/_self", CV::FsUserCtrl, :_self
    get "/user/logout", CV::FsUserCtrl, :logout
    post "/user/login", CV::FsUserCtrl, :login
    post "/user/signup", CV::FsUserCtrl, :signup
    post "/user/setting", CV::FsUserCtrl, :update

    get "/books", CV::FsBookCtrl, :index
    get "/books/:bslug", CV::FsBookCtrl, :show
    get "/users/:uname/books", CV::FsBookCtrl, :user_books

    get "/cvbooks", CV::CvbookCtrl, :index
    get "/cvbooks/:bslug", CV::CvbookCtrl, :show

    get "/chaps/:bhash/:sname/:snvid", CV::FsChapCtrl, :index
    get "/chaps/:bhash/:sname/:snvid/:page", CV::FsChapCtrl, :paged

    get "/cvchaps/:bhash/:sname", CV::CvchapCtrl, :index

    get "/texts/:bname/:sname/:snvid/:chidx", CV::FsTextCtrl, :show
    get "/texts/:bname/:sname/:snvid/:chidx/:schid", CV::FsTextCtrl, :convert
    put "/texts/:bname/:sname/:snvid", CV::FsTextCtrl, :upsert

    get "/mark-books/:bname", CV::FsMarkCtrl, :show
    put "/mark-books/:bname", CV::FsMarkCtrl, :update
    get "/mark-chaps", CV::FsMarkCtrl, :history

    get "/dicts", CV::VpDictCtrl, :index
    get "/dicts/:dname", CV::VpDictCtrl, :show
    get "/dicts/:dname/lookup", CV::VpDictCtrl, :lookup
    put "/dicts/:dname/lookup", CV::VpDictCtrl, :lookup
    get "/dicts/:dname/search", CV::VpDictCtrl, :search
    put "/dicts/:dname/search", CV::VpDictCtrl, :search
    put "/dicts/:dname/upsert", CV::VpDictCtrl, :upsert

    post "/tools/convert/:dname", CV::VpToolCtrl, :convert
    get "/qtran/:name", CV::VpToolCtrl, :show
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
