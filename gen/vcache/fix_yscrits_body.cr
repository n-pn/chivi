ENV["CV_ENV"] = "production"

require "../../src/_data/_data"

remove = File.read_lines("/srv/chivi/zroot/yscrit-vi_bd-mismatch.log", chomp: true).map(&.to_i)
puts remove
PGDB.exec "update yscrits set vi_bd = null where id = any ($1)", remove
