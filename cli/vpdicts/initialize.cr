require "../../src/kernel/models/book_info"
require "../../src/kernel/filedb/value_set"

def split_chars(input)
  input.split("").each do |char|
    yield char if char =~ /\p{Han}/
  end
end

def extract_crucial_chars
  file = "var/libcv/initial/autogen/crutial-chars.txt"
  dict = ValueSet.new(file, mode: 0)

  infos = BookInfo.load_all!
  infos.each do |info|
    split_chars(info.zh_title) { |x| dict.upsert(x) }
    split_chars(info.zh_author) { |x| dict.upsert(x) }
  end

  dict.save!
end

extract_crucial_chars
