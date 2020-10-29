require "../../src/filedb/order_map"

def test_map(name, limit = 0)
  map = OrderMap.new("tmp/#{name}.tsv", preload: true)
  map.reverse_each do |node|
    pp node
    limit += 1
    break if limit > 20
  end
end

test_map("map-ordered")
test_map("map-random")

map = OrderMap.new("tmp/map-random-sorted.tsv", preload: false)
map.load!("tmp/map-random.tsv")
map.save!
