# require "./models/book_info"
# require "./models/book_misc"

# module BookRepo
#   extend self

#   INFO_DIR = File.join("var", "appcv", "book_infos")
#   MISC_DIR = File.join("var", "appcv", "book_miscs")

#   def setup!
#     FileUtils.mkdir_p(INFO_DIR)
#     FileUtils.mkdir_p(MISC_DIR)
#   end

#   def reset!
#     FileUtils.rm_rf(INFO_DIR)
#     FileUtils.rm_rf(MISC_DIR)
#     setup!
#   end

#   def info_path(uuid : String)
#     File.join(INFO_DIR, "#{uuid}.json")
#   end

#   def misc_path(uuid : String)
#     File.join(MISC_DIR, "#{uuid}.json")
#   end

#   INFOS = {} of String => BookInfo
#   MISCS = {} of String => BookMisc

#   def load_info!(uuid : String)
#     INFOS[uuid] ||= read
#   end

#   def load_misc!(uuid : String)
#     INFOS[uuid] ||= read_misc!()
#   end

#   def save

# end
