require "mime"
require "digest"
require "colorize"
require "file_utils"

files = Dir.glob("_db/.cover/.miscs/*/*.*")

puts files.size
