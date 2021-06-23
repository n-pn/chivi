Amber::Server.configure do
  pipeline :api do
    # plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::ClientIp.new(["X-Forwarded-For"])
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new(filter: ["upass"])
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
    get "/_self", CV::UserCtrl, :_self
    post "/login", CV::UserCtrl, :login
    get "/logout", CV::UserCtrl, :logout
    post "/signup", CV::UserCtrl, :signup

    get "/books", CV::BookCtrl, :index
    get "/books/:bslug", CV::BookCtrl, :show
    get "/users/:uname/books", CV::BookCtrl, :user_books

    get "/chaps/:bhash/:zseed/:snvid", CV::ChapCtrl, :index
    get "/chaps/:bhash/:zseed/:snvid/:page", CV::ChapCtrl, :paged

    get "/texts/:bname/:zseed/:snvid/:chidx", CV::TextCtrl, :show
    get "/texts/:bname/:zseed/:snvid/:chidx/:schid", CV::TextCtrl, :convert
    put "/texts/:bname/:zseed/:snvid", CV::TextCtrl, :upsert

    get "/mark-books/:bname", CV::MarkCtrl, :show
    put "/mark-books/:bname", CV::MarkCtrl, :update
    get "/mark-chaps", CV::MarkCtrl, :history

    get "/dicts", CV::DictCtrl, :index
    get "/dicts/:dname", CV::DictCtrl, :show
    get "/dicts/:dname/lookup", CV::DictCtrl, :lookup
    put "/dicts/:dname/lookup", CV::DictCtrl, :lookup
    get "/dicts/:dname/search", CV::DictCtrl, :search
    put "/dicts/:dname/search", CV::DictCtrl, :search
    put "/dicts/:dname/upsert", CV::DictCtrl, :upsert

    post "/tools/convert/:dname", CV::ToolCtrl, :convert
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
