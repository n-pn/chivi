require "./webcv/*"

Kemal::Session.config do |config|
  config.cookie_name = "chivi"
  config.secret = ENV["SECRET"]? || "chivi-session"
  config.timeout = 3.days
  config.engine = Kemal::Session::FileEngine.new({:sessions_dir => "config/session"})
  config.gc_interval = 5.minutes
  config.secure = Kemal.config.env == "production"
end

module CV::Server
  Kemal.config.port = ENV["PORT"]?.try(&.to_i?) || 5010
  serve_static false

  Kemal.run
end
