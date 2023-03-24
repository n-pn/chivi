require "log"

# ameba:disable Style/TypeNames
module CV_ENV
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

  class_getter be_port = ENV["CV_BE_PORT"]?.try(&.to_i?) || 5010 # current api server
  class_getter wn_port = ENV["CV_WN_PORT"]?.try(&.to_i?) || 5020 # current api server

  class_getter m0_port = ENV["CV_M0_PORT"]?.try(&.to_i?) || 5100 # mt_v0 engine
  class_getter m1_port = ENV["CV_M1_PORT"]?.try(&.to_i?) || 5110 # mt_v1 engine
  class_getter m2_port = ENV["CV_M2_PORT"]?.try(&.to_i?) || 5120 # mt_v2 engine

  class_getter sp_port = ENV["CV_SP_PORT"]?.try(&.to_i?) || 5300 # mt_sp helper
  class_getter ys_port = ENV["CV_YS_PORT"]?.try(&.to_i?) || 5400 # ysapp server

  class_getter be_host = "http://localhost:#{be_port}"
  class_getter wn_host = "http://localhost:#{wn_port}"
  class_getter m1_host = "http://localhost:#{m1_port}"
  class_getter sp_host = "http://localhost:#{sp_port}"
  class_getter ys_host = "http://localhost:#{ys_port}"
end
