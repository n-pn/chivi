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
    get "/user/_self", CV::UserCtrl, :_self
    get "/user/logout", CV::UserCtrl, :logout
    post "/user/login", CV::UserCtrl, :login
    post "/user/signup", CV::UserCtrl, :signup
    put "/user/setting", CV::UserCtrl, :update
    put "/user/passwd", CV::UserCtrl, :passwd

    get "/books", CV::BookCtrl, :index
    get "/books/find/:bname", CV::BookCtrl, :find
    get "/books/:bslug", CV::BookCtrl, :show

    get "/chaps/:book/:sname", CV::ChapCtrl, :index
    get "/chaps/:book/:sname/:chidx", CV::ChapCtrl, :show
    get "/chaps/:book/:sname/:chidx/:schid", CV::ChapCtrl, :text
    post "/chaps/:book/:sname", CV::ChapCtrl, :upsert

    get "/crits", CV::CritCtrl, :index
    get "/crits/:crit", CV::CritCtrl, :show
    get "/crits/:crit/replies", CV::CritCtrl, :replies

    get "/ubmarks/:bname", CV::MemoCtrl, :show

    get "/_self/history", CV::MemoCtrl, :history
    get "/_self/library", CV::MemoCtrl, :library

    put "/_self/library/:book_id", CV::MemoCtrl, :update_library
    put "/_self/history/:book_id", CV::MemoCtrl, :update_history

    get "/dicts", CV::DictCtrl, :index
    get "/dicts/:dname", CV::DictCtrl, :show
    get "/dicts/:dname/lookup", CV::DictCtrl, :lookup
    put "/dicts/:dname/lookup", CV::DictCtrl, :lookup
    get "/dicts/:dname/search", CV::DictCtrl, :search
    put "/dicts/:dname/search", CV::DictCtrl, :search
    put "/dicts/:dname/upsert", CV::DictCtrl, :upsert

    post "/tools/convert/:dname", CV::ToolCtrl, :convert
    get "/qtran/:name", CV::ToolCtrl, :show
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
