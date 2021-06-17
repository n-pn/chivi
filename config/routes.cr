Amber::Server.configure do
  pipeline :api do
    # plug Amber::Pipe::PoweredByAmber.new
    # plug Amber::Pipe::ClientIp.new(["X-Forwarded-For"])
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
    get "/@:uname/books", CV::BookCtrl, :user_books

    get "/chseeds/:bhash/:sname/:snvid", CV::ChapCtrl, :index
    get "/chitems/:bhash/:sname/:snvid", CV::ChapCtrl, :paged

    get "/mark-books/:bname", CV::MarkCtrl, :show
    put "/mark-books/:bname", CV::MarkCtrl, :update

    get "/mark-chaps", CV::MarkCtrl, :history
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
