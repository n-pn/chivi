require "../../src/bookdb/book_repo"

def test_search(query)
  puts
  puts query.to_pretty_json.colorize.blue

  BookRepo.search(query).each do |info|
    brief = {info.ubid, info.title_vi, info.author_vi, info.genres_vi, info.weight, info.rating}
    puts brief.colorize.cyan
  end
end

puts BookRepo.get("4avvz9sx").try(&.title_vi)
puts BookRepo.get("gbzfa3em").try(&.title_vi)
puts BookRepo.find("nhat-quyen-tay-lai").try(&.title_vi)

test_search BookRepo::Query.new(order: "rating")
test_search BookRepo::Query.new(order: "weight", offset: 0)
test_search BookRepo::Query.new(order: "weight", offset: 9)
test_search BookRepo::Query.new(order: "weight", cursor: "b4g441q8")
test_search BookRepo::Query.new(order: "weight", offset: 30000)
test_search BookRepo::Query.new(order: "weight", cursor: "s0fvndb7")

test_search BookRepo::Query.new(query: "Cơ Xoa", type: :author)
test_search BookRepo::Query.new(query: "Van dao", type: :fuzzy)
test_search BookRepo::Query.new(genre: "Do thi", limit: 10, query: "van dao")
test_search BookRepo::Query.new(genre: "Do thi", limit: 10, offset: 9)
test_search BookRepo::Query.new(genre: "Do thi", limit: 10, cursor: "k917ycab")

# test_search BookRepo::Query.new(query: "dai phung")
