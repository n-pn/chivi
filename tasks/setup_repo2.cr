require "../src/appcv/nvchap/ch_repo_2"

1.upto(6235).each do |idx|
  repo = CV::ChRepo2.new("hetushu", idx.to_s, reset: false)
  repo.update!
  puts repo.count
end
