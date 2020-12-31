require "../../src/filedb/stores/order_map"

def test_map(name, limit = 10)
  map = CV::OrderMap.new(".tmp/#{name}.tsv", mode: 1)

  map._idx.each.first(limit).each do |node|
    pp [node.key, node.val]
  end

  map._idx.reverse_each.first(limit).each do |node|
    pp [node.key, node.val]
  end
end

test_map("map-random")
test_map("map-sorted")

map = CV::OrderMap.new(".tmp/map-random-sorted.tsv", mode: 0)
map.load!(".tmp/map-random.tsv")
map.save!
