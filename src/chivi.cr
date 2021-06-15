require "./webcv/*"

Kemal::Session.config do |config|
  config.cookie_name = "chivi"
  config.secret = ENV["SECRET"]? || "chivi-session"
  config.timeout = 4.weeks
  config.engine = Kemal::Session::FileEngine.new({:sessions_dir => "etc/sessions"})
  config.gc_interval = 10.minutes
  config.secure = Kemal.config.env == "production"
end

module CV::Server
  Kemal.config.port = ENV["PORT"]?.try(&.to_i?) || 5010
  Kemal.run
end
