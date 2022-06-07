class CV::MtlV2::Server::QtranCtrl < BaseCtrl
  base "/"

  @[AC::Route::GET("/")]
  def index
    welcome_text = "You're being trampled by Spider-Gazelle!"
    Log.warn { "logs can be collated using the request ID" }

    # You can use signals to change log levels at runtime
    # USR1 is debugging, USR2 is info
    # `kill -s USR1 %APP_PID`
    Log.debug { "use signals to change log levels at runtime" }

    welcome_text
  end
end
