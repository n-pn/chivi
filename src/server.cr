require "kemal"
require "./kernel"

module Server
  serve_static false

  before_all do |env|
    env.response.content_type = "application/json"
  end

  get "/" do |env|
    {msg: "ok"}.to_json env.response
  end

  Kemal.run
end
