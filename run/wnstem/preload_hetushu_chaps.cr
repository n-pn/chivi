# require "sqlite3"
# require "colorize"
# require "../../src/zroot/rmstem"

# DB3_DIR = "/srv/chivi/zroot/wnchap/!hetushu"
# HTM_DIR = "/srv/chivi/.keep/rmchap/!hetushu"

# def fetch_html(host : Rmhost, queue : Array({String, String, Int32}))
#   q_size = queue.size
#   w_size = q_size
#   w_size = 6 if w_size > 6

#   workers = Channel({String, String, Int32}).new(q_size)
#   results = Channel(Nil).new(w_size)

#   w_size.times do
#     spawn do
#       loop do
#         save_path, chap_link, idx = workers.receive
#         host.save_page(chap_link, save_path)
#         puts "- #{idx}/#{q_size}  #{chap_link.colorize.blue} saved!"
#       rescue err
#         Log.error(exception: err) { err.message.colorize.red }
#       ensure
#         results.send(nil)
#       end
#     end
#   end

#   queue.each { |entry| workers.send(entry) }
#   q_size.times { results.receive }
# end

# def fetch_json(host : Rmhost, queue : Array({String, String, Int32}))
#   q_size = queue.size
#   w_size = q_size
#   w_size = 6 if w_size > 6

#   workers = Channel({String, String, Int32}).new(q_size)
#   results = Channel(Nil).new(w_size)

#   w_size.times do
#     spawn do
#       loop do
#         chap_path, chap_link, idx = workers.receive

#         json_path = chap_path.sub(".htm", ".tok")
#         json_link = chap_link.sub(/(\d+).html$/) { "r#{$1}.json" }

#         host.http_client.get(json_link, headers: host.xhr_headers(chap_link)) do |res|
#           raise "Can't download decode string" unless res.success?
#           res.headers["token"].tap { |x| File.write(json_path, x) }
#         end

#         puts "- #{idx}/#{q_size} #{json_link.colorize.blue} saved!"
#       rescue err
#         Log.error(exception: err) { err.message.colorize.red }
#       ensure
#         results.send(nil)
#       end
#     end
#   end

#   queue.each { |entry| workers.send(entry) }
#   q_size.times { results.receive }
# end

# def preload_book(host : Rmhost, bid : Int32)
#   db_path = "#{DB3_DIR}/#{bid}.db3"
#   return unless File.file?(db_path)

#   query = "select spath from chinfos where cksum = ''"
#   spaths = DB.open("sqlite3:#{db_path}", &.query_all(query, as: String))

#   if spaths.empty?
#     puts "- #{bid} all chap saved, skipping"
#     return
#   end

#   sc_ids = spaths.map { |x| File.basename(x) }
#   to_save = sc_ids.size

#   htm_dir = "#{HTM_DIR}/#{bid}"

#   if File.directory?(htm_dir)
#     sc_ids -= Dir.children(htm_dir).map!(&.sub(".tok", ""))
#   else
#     Dir.mkdir_p(htm_dir)
#   end

#   if spaths.empty?
#     puts "- #{bid} all chap cached, skipping"
#     return
#   end

#   puts "- total: #{to_save}, missing: #{sc_ids.size}"

#   queue = sc_ids.map_with_index(1) do |cid, idx|
#     save_path = "#{htm_dir}/#{cid}.htm"
#     chap_path = host.make_chap_path(bid, cid)
#     {save_path, chap_path, idx}
#   end

#   fetch_html(host, queue)
#   fetch_json(host, queue)
# end

# seed = Rmhost.from_host!("www.hetushu.com")

# seed.get_max_bid.to_i.downto(1) do |bid|
#   preload_book(seed, bid)
# end
