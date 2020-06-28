require "./routes/*"

module Server
  Kemal.config.port = 5110

  serve_static false

  before_all do |env|
    case Kemal.config.env
    when "development"
      udic = "local"
    when "test"
      udic = "_test"
    else
      udic = "appcv"
    end

    env.set("udic", udic)
    env.response.content_type = "application/json"
  end

  get "/_/" do |env|
    {msg: "ok"}.to_json env.response
  end

  Kemal.run
end
