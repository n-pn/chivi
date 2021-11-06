require "file_utils"
require "../shared/bootstrap"

module CV
  USER_DIR = "db/seeds/users"

  YSCRIT_DIR = "var/yousuu/yscrits"

  FileUtils.mkdir_p(YSCRIT_DIR)
end
