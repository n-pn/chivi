require "./webcv/*"

Kemal::Session.config do |config|
  config.cookie_name = "chivi"
  config.secret = ENV["SECRET"]? || "chivi-session"
  config.timeout = 4.weeks
  config.engine = Kemal::Session::FileEngine.new({:sessions_dir => "priv/_users"})
  config.gc_interval = 15.minutes
  config.secure = Kemal.config.env == "production"
end

module CV::Server
  public_folder "priv/static"

  Kemal.config.port = ENV["PORT"]?.try(&.to_i?) || 5010
  Kemal.run
end
