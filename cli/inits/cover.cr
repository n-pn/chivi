require "../../src/appcv/lookup/label_map"

CACHE_DIR = File.join("var", "appcv", ".cached")

class InitBookCover
  def sitemap(seed : String)
    file = File.join(DIR, ".cached", seed, "covers.txt")
    LabelMap.load(file, mode: 1)
  end
end
