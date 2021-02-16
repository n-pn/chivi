require "file_utils"

DIR = "_db/chdata/chinfos"

ORIG_DIR = "_db/chdata/chorigs"
HEAD_DIR = "_db/chdata/chheads"

FileUtils.mkdir_p(ORIG_DIR)
FileUtils.mkdir_p(HEAD_DIR)

Dir.children(DIR).each do |sname|
  FileUtils.mv("#{DIR}/#{sname}/origs", "#{ORIG_DIR}/#{sname}")
  FileUtils.mv("#{DIR}/#{sname}/infos", "#{HEAD_DIR}/#{sname}")
end
