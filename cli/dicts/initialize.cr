require "../../src/kernel/book_info"

def split_hanzi(input)
  input.split("").each do |char|
    yield char if char =~ /\p{Han}/
  end
end

def extract_common_hanzi
  common = Set(String).new

  infos = BookInfo.load_all!
  infos.each_value do |info|
    split_hanzi(info.title_zh) { |x| common << x }
    split_hanzi(info.author_zh) { |x| common << x }
  end

  puts "- common hanzi: #{common.size}"

  File.write "var/.dict_inits/autogen/common-hanzi.txt", common.to_a.join("\n")
end
