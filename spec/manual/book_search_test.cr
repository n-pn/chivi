require "../../src/kernel/book_search"

def test_search(opts)
  puts
  puts opts.colorize.blue

  BookSearch.fetch!(opts).each do |info|
    brief = {info.ubid, info.vi_title, info.vi_author, info.vi_genres, info.weight, info.rating}
    puts brief.colorize.cyan
  end
end

test_search BookSearch::Opts.new(order: :rating)
test_search BookSearch::Opts.new(order: :weight, offset: 0)
test_search BookSearch::Opts.new(order: :weight, offset: 9)
test_search BookSearch::Opts.new(order: :weight, anchor: "b4g441q8")
test_search BookSearch::Opts.new(order: :weight, offset: 30000)
test_search BookSearch::Opts.new(order: :weight, anchor: "s0fvndb7")

test_search BookSearch::Opts.new(query: "Cơ Xoa", type: :author)
test_search BookSearch::Opts.new(query: "Van dao", type: :fuzzy)
test_search BookSearch::Opts.new(genre: "Do thi", limit: 10, query: "van dao")
test_search BookSearch::Opts.new(genre: "Do thi", limit: 10, offset: 9)
test_search BookSearch::Opts.new(genre: "Do thi", limit: 10, anchor: "k917ycab")

# test_search BookSearch::Opts.new(query: "dai phung")
