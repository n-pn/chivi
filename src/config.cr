require "log"

module CV::Config
  def self.load_env(file : String = ".env")
    File.each_line(file) do |line|
      next unless line =~ /^\s*(\w+)\s*=\s*(.+?)\s*$/
      ENV[$1] ||= $2 # do not overwrite
    end
  end

  class_getter? production : Bool = ENV["CV_ENV"]? == "production"

  self.load_env(".env.production") if self.production?
  self.load_env(".env")

  class_getter database_url : String = ENV["CV_DATABASE_URL"]

  class_getter ses_username : String = ENV["CV_SES_USERNAME"]
  class_getter ses_password : String = ENV["CV_SES_PASSWORD"]

  class_getter session_skey : String = ENV["CV_SESSION_SKEY"]

  class_getter log_severity : Log::Severity = self.production? ? Log::Severity::Error : Log::Severity::Debug

  class_getter be_port = 5010 # current api server
  class_getter wn_port = 5020 # raw novel data
  class_getter ys_port = 5509 # yousuu content

  class_getter m0_port = 5500 # mt_v0 engine
  class_getter m1_port = 5501 # mt_v1 engine
  class_getter m2_port = 5502 # mt_v2 engine
  class_getter ms_port = 5501 # mt_sp helper

end
