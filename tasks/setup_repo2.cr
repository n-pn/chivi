require "../src/appcv/nvchap/ch_repo_2"
test = CV::ChRepo2.new("hetushu", "4442", reset: true)

puts test.count
test.update!
puts test.count
