require "../../src/bookdb/book_info"
require "../../src/lookup/value_set"

def split_chars(input)
  input.split("").each do |char|
    yield char if char =~ /\p{Han}/
  end
end

def extract_crucial_chars
  crucial = ValueSet.new("var/.dict_inits/autogen/crutial-chars.txt", mode: 0)

  infos = BookInfo.load_all!
  infos.each do |info|
    split_chars(info.zh_title) { |x| crucial.upsert(x) }
    split_chars(info.zh_author) { |x| crucial.upsert(x) }
  end

  crucial.save!
end

extract_crucial_chars
