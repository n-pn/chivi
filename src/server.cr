require "./routes/*"

module Server
  Kemal.config.port = 5110
  serve_static false

  before_all do |env|
    env.response.content_type = "application/json"

    if cookie = env.request.cookies["uslug"]?
      env.set("uslug", cookie.value)
    end
  end

  get "/" do |env|
    {msg: "ok"}.to_json env.response
  end

  Kemal.run
end
