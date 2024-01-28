require "colorize"
require "http/client"

FIRST_PAGE = "http://vietnamtudien.hoangxuanhan.org/_db/hanDict/%{word}"
NEXT_PAGES = "http://vietnamtudien.hoangxuanhan.org/_db/hanDict/_%{word},%{page}"

words = File.read_lines("run/trichdan/data/hanzi.tsv").map(&.split('\t').first)

def fetch(word : String, force = false)
  url = FIRST_PAGE % {word: word}
  puts "GET: #{url}"

  out_path = "var/inits/trichdan/#{word}.json"
  return if !force && File.exists?(out_path)

  HTTP::Client.get(url) do |res|
    File.write(out_path, res.body_io.gets_to_end)
  end
end

def crawl(words : Array(String), threads = 6)
  queue = Channel(String).new(words.size)
  catch = Channel(Nil).new(threads)

  spawn do
    words.each { |word| queue.send(word) }
  end

  threads.times do
    spawn do
      loop do
        fetch(queue.receive)
      rescue err
        Log.error(exception: err) { err.message.colorize.red }
      ensure
        catch.send(nil)
      end
    end
  end

  words.size.times { catch.receive }
end

# fetch("一", force: true)
crawl(words)
