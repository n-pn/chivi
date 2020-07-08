require "./routes/*"

module Server
  Kemal.config.port = 5110
  serve_static false

  before_all do |env|
    case Kemal.config.env
    when "development"
      uname = "local"
    when "test"
      uname = "test"
    else
      uname = "guest"
    end

    env.set("uname", uname)
    env.response.content_type = "application/json"
  end

  get "/" do |env|
    {msg: "ok"}.to_json env.response
  end

  Kemal.run
end
