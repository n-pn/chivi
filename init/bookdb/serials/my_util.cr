require "../../../src/engine"
require "../../../src/crawls/cr_info"

module MyUtil
  extend self

  def hanviet(input : String)
    return input unless input =~ /\p{Han}/
    Engine.hanviet(input).map(&.val).join
  end

  def translate(input : String, title = false)
    return input if input.empty?
    Engine.convert(input, title: title).map(&.val).join
  end

  def load_sitemap(site)
    inp = "data/txt-tmp/sitemap/#{site}.json"
    map = Hash(String, String).from_json File.read(inp)

    puts "- <#{site}>: #{map.size} entries".colorize(:cyan)

    dir = "data/txt-tmp/sitemap/#{site}/"
    return map unless File.exists? dir

    bsids = Dir.children(dir).map { |x| File.basename(x, ".txt") }
    items = Set(String).new(bsids)

    map.reject! { |key, val| items.includes?(val) }
    puts "- <#{site}> ignore blacklist: #{map.size} entries".colorize(:cyan)

    map
  end
end
