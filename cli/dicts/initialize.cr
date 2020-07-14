require "../../src/models/book_info"
require "../../src/lookup/value_set"

def split_chars(input)
  input.split("").each do |char|
    yield char if char =~ /\p{Han}/
  end
end

def extract_crucial_chars
  crucial = ValueSet.new("var/.dict_inits/autogen/crutial-chars.txt", false)

  infos = BookInfo.load_all!
  infos.each do |info|
    split_chars(info.title_zh) { |x| crucial.upsert(x) }
    split_chars(info.author_zh) { |x| crucial.upsert(x) }
  end

  crucial.save!
end

extract_crucial_chars
