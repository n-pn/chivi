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

  class_getter jwt_access_sk : String = ENV["CV_JWT_ACCESS_SK"]
  class_getter jwt_refresh_sk : String = ENV["CV_JWT_REFRESH_SK"]
end
