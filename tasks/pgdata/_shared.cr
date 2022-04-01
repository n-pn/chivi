require "file_utils"
require "../shared/bootstrap"

module CV
  CVUSER_DIR = "var/pg_data/cvusers"
  YSCRIT_DIR = "var/yousuu/yscrits"

  FileUtils.mkdir_p(CVUSER_DIR)
  FileUtils.mkdir_p(YSCRIT_DIR)

  def self.user_file(uname : String)
    File.join(CVUSER_DIR, uname.downcase + ".tsv")
  end
end
