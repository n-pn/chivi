require "./routes/*"

Kemal::Session.config do |config|
  config.cookie_name = "chivi"
  config.secret = ENV["SECRET"]? || "d954684990fd34f6232918376e4e9f93423423444d"
  config.timeout = 3.days
  config.engine = Kemal::Session::FileEngine.new({:sessions_dir => "tmp/"})
  config.gc_interval = 5.minutes # 5 minutes
end

module Server
  Kemal.config.port = 5110
  serve_static false

  before_all do |env|
    env.response.content_type = "application/json"
  end

  get "/" do |env|
    {msg: "ok"}.to_json env.response
  end

  Kemal.run
end
