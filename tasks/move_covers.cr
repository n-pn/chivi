require "mime"
require "digest"
require "colorize"
require "http/client"
require "file_utils"

require "../src/kernel/models/book_info"

TMP_DIR = "_db/_covers"
# FILE_DF = File.join(TMP_DIR, "blank.jpg")
infos = BookInfo.load_all!
infos.each do |info|
  info.covers.each do |site, link|
    name = Digest::SHA1.hexdigest(link)[0..10]
  end
end
