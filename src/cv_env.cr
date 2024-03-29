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

  class_getter be_port = ENV["CV_BE_PORT"]?.try(&.to_i?) || 5010 #
  class_getter be_host = "http://localhost:#{be_port}"

  class_getter wn_port = ENV["CV_WN_PORT"]?.try(&.to_i?) || 5020 #
  class_getter wn_host = "http://localhost:#{wn_port}"

  class_getter up_port = ENV["CV_UP_PORT"]?.try(&.to_i?) || 5030 #
  class_getter up_host = "http://localhost:#{up_port}"

  class_getter rd_port = ENV["CV_RD_PORT"]?.try(&.to_i?) || 5200
  class_getter rd_host = "http://localhost:#{rd_port}"

  class_getter sp_port = ENV["CV_SP_PORT"]?.try(&.to_i?) || 5300 # mt_sp helper
  class_getter sp_host = "http://localhost:#{sp_port}"

  class_getter ys_port = ENV["CV_YS_PORT"]?.try(&.to_i?) || 5400 # ysapp server
  class_getter ys_host = "http://localhost:#{ys_port}"

  class_getter lp_host = ENV["HANLP_HOST"]

  class_getter m1_port = ENV["MT_V1_PORT"].to_i? || 5110
  class_getter m1_host = ENV["MT_V1_HOST"]

  class_getter ai_port = ENV["CV_AI_PORT"].to_i? || 5120
  class_getter ai_host = ENV["CV_AI_HOST"]

  class_getter c_gpt_host = ENV["C_GPT_HOST"]
  class_getter m_gpt_host = ENV["M_GPT_HOST"]
end
