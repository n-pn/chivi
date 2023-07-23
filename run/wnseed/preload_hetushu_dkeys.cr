require "../../src/tasks/remote/shared/rmseed"

HTM_DIR = "/2tb/var.chivi/.keep/wnchap/www.hetushu.com"
TXT_DIR = "var/texts/rgbks/!hetushu.com"

def preload_book(bid : Int32)
  htm_dir = "#{HTM_DIR}/#{bid}"
  Dir.mkdir_p(htm_dir)

  files = Dir.children(htm_dir)
  return if files.empty?

  all_ids = files.select(&.ends_with?(".htm")).map!(&.sub(".htm", ""))
  total = all_ids.size

  all_ids -= files.map!(&.sub(".tok", ""))
  puts "- total: #{total}, missing: #{all_ids.size}"

  q_size = all_ids.size
  w_size = q_size
  w_size = 6 if w_size > 6

  workers = Channel({String, Int32}).new(q_size)
  results = Channel(Nil).new(w_size)

  w_size.times do
    spawn do
      loop do
        cid, idx = workers.receive
        headers = HTTP::Headers{
          "Referer"          => "https://www.hetushu.com/book/#{bid}/#{cid}.html",
          "Content-Type"     => "application/x-www-form-urlencoded",
          "X-Requested-With" => "XMLHttpRequest",
          "Cookie"           => "PHPSESSID=48grk8h3bi58q13rhbjp1kaa73",
        }

        json_link = "https://www.hetushu.com/book/#{bid}/r#{cid}.json"

        HTTP::Client.get(json_link, headers: headers) do |res|
          raise "Can't download encrypt data" unless res.success?
          File.write("#{htm_dir}/#{cid}.tok", res.headers["token"])
        end

        puts "- #{idx}/#{q_size} #{json_link.colorize.blue} saved!"
      rescue err
        Log.error(exception: err) { err.message.colorize.red }
      ensure
        results.send(nil)
      end
    end
  end

  all_ids.each_with_index(1) { |cid, idx| workers.send({cid, idx}) }
  q_size.times { results.receive }
end

seed = Rmseed.from("www.hetushu.com")

seed.get_mbid.to_i.downto(1) do |bid|
  preload_book(bid)
end
